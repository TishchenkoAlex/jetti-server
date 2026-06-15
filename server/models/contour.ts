import { COMPANY_BY_CONTOUR_CACHE_TTL_SECONDS, CONTOUR } from "../env/environment";
import { MSSQL } from "../mssql";
import { lib } from "../std.lib";

type ContourId = 0 | 1 | 2 | 3;

type ContourCacheItem = {
    contour: ContourId;
    expiresAt: number;
};

export class Contour {

    private static contourCache = new Map<string, ContourCacheItem>();

    static get roleReadonlyContourEditor() {
        return 'Readonly company contour editor';
    }

    static get roleCommonDataEditor() {
        return 'Common data editor';
    }

    static get roleMirrorContourEditor() {
        return 'Mirror contour editor';
    }

    static get contour(): ContourId {
        return CONTOUR as ContourId;
    }

    static get contourMirror(): ContourId {
        return this.contour === 1 ? 2 : 1;
    }

    static get commonContour() {
        return 0 as ContourId;
    }

    static get readonlyContour() {
        return 3 as ContourId;
    }

    static get autoMirrorContour() {
        return this.readonlyContour;
    }

    static async contourByCompany(company: string | undefined | null, tx?: MSSQL): Promise<ContourId | -1> {
        if (!company) return -1;

        const cached = this.contourCache.get(company);

        if (cached) {
            const isExpired = Date.now() > cached.expiresAt;

            if (!isExpired) {
                return cached.contour;
            }

            this.contourCache.delete(company);
        }

        const contour = await this.getContourByCompany(company, tx);
        
        if (contour === -1) { 
            return contour; 
        }

        this.contourCache.set(company, { contour, expiresAt: Date.now() + COMPANY_BY_CONTOUR_CACHE_TTL_SECONDS * 1000 });

        return contour;
    }

    static clearCache() {
        this.contourCache.clear();
    }

    static async isCommonDataContourCompany(company: string | undefined | null, tx?: MSSQL): Promise<boolean> {
        if (!company) return false;
        const contour = await this.contourByCompany(company, tx);
        return contour === this.commonContour || contour === this.readonlyContour;
    }

    static async isOwnContourCompany(company: string | undefined | null, tx?: MSSQL): Promise<boolean> {
        const contour = await this.contourByCompany(company, tx);
        return this.contour === contour;
    }

    static async isCommonContourCompany(company: string | undefined | null, tx?: MSSQL): Promise<boolean> {
        const contour = await this.contourByCompany(company, tx);
        return this.commonContour === contour;
    }

    static async isAutoMirrorContourCompany(company: string | undefined | null, tx?: MSSQL): Promise<boolean> {
        const contour = await this.contourByCompany(company, tx);
        return this.autoMirrorContour === contour;
    }

    static isCommonDataEditor(tx?: MSSQL): boolean {
        return tx?.isRoleAvailable(this.roleCommonDataEditor) ?? false;
    }

    static isReadonlyContourEditor(tx?: MSSQL): boolean {
        return tx?.isRoleAvailable(this.roleReadonlyContourEditor) ?? false
    }

    static isMirrorContourEditor(tx?: MSSQL): boolean {
        return tx?.isRoleAvailable(this.roleMirrorContourEditor) ?? false
    }

    static async isReadOnlyContourCompany(company: string | undefined | null, tx?: MSSQL): Promise<boolean> {
        if (!company || tx?.isMirrorContourOperation()) return false;

        const contour = await this.contourByCompany(company, tx);
        const isOwnContour = this.contour === contour;
        if (isOwnContour) return false;
        const isMirrorContour = this.contourMirror === contour;
        if (isMirrorContour) return !this.isMirrorContourEditor(tx);
        const isCommonContour = this.commonContour === contour;
        if (isCommonContour) return !this.isCommonDataEditor(tx);
        const isReadOnlyContour = this.readonlyContour === contour;
        if (isReadOnlyContour) return !this.isCommonDataEditor(tx) && !this.isReadonlyContourEditor(tx);
        return false;
    }

    private static async getContourByCompany(company: string | undefined | null, tx?: MSSQL): Promise<ContourId | -1> {
        if (!company) return -1;
        const db = tx ?? lib.util.jettiPoolTx();
        const { contour = 0 } = await db.oneOrNone<{ contour: ContourId }>(`SELECT [dbo].[ContourByCompany] (@p1) contour`, [company]) ?? {};
        return contour;
    }
    
}
