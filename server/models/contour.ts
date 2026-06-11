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

    static get contour(): ContourId {
        return CONTOUR as ContourId;
    }

    static get contourMirror(): ContourId {
        return this.contour === 1 ? 2 : 1;
    }

    static get commonContours() {
        return [0, 3] as ContourId[];
    }

    static async contourByCompany(company: string | undefined, tx?: MSSQL): Promise<ContourId> {
        if (!company) return 0;

        const cached = this.contourCache.get(company);

        if (cached) {
            const isExpired = Date.now() > cached.expiresAt;

            if (!isExpired) {
                return cached.contour;
            }

            this.contourCache.delete(company);
        }

        const { contour = 0 } = (await (tx ?? lib.util.jettiPoolTx()).oneOrNone<{ contour: ContourId }>(`SELECT [dbo].[ContourByCompany] (@p1) contour`, [company])) ?? {};

        this.contourCache.set(company, { contour, expiresAt: Date.now() + COMPANY_BY_CONTOUR_CACHE_TTL_SECONDS * 1000 });

        return contour;
    }

    static clearCache() {
        this.contourCache.clear();
    }

    static async isOwnContourCompany(company: string | undefined, tx?: MSSQL): Promise<boolean> {
        const contour = await this.contourByCompany(company, tx);
        return this.contour === contour;
    }

    static isReadOnlyContour(contour: ContourId) {
        return (!this.commonContours.includes(contour) && contour !== this.contour);
    }

    static isOwnContour(contour: ContourId) {
        return contour === this.contour;
    }
}
