import { RegisterRlsPeriod } from "../../../models/register.info.rls.period";
import { IRuleContext } from "../../../models/registers.movements";

export async function checkRlsUpdate({ rlsPartition }: IRuleContext) {
    rlsPartition && RegisterRlsPeriod.updatePartitionInCache(rlsPartition);
}