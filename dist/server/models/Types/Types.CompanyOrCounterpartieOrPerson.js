"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TypesCompanyOrCounterpartieOrPerson = void 0;
const documents_factory_1 = require("../documents.factory");
const TypesBase_1 = require("./TypesBase");
class TypesCompanyOrCounterpartieOrPerson extends TypesBase_1.TypesBase {
    getTypes() {
        return documents_factory_1.RegisteredDocumentsTypes(type => ['Catalog.Company', 'Catalog.Counterpartie', 'Catalog.Person']
            .includes(type));
    }
}
exports.TypesCompanyOrCounterpartieOrPerson = TypesCompanyOrCounterpartieOrPerson;
//# sourceMappingURL=Types.CompanyOrCounterpartieOrPerson.js.map