"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CatalogScenario = void 0;
const jetti_middle_1 = require("jetti-middle");
let CatalogScenario = class CatalogScenario extends jetti_middle_1.DocumentBase {
    constructor() {
        super(...arguments);
        this.parent = null;
        this.currency = null;
    }
};
__decorate([
    jetti_middle_1.Props({ type: 'Catalog.Scenario', hiddenInList: true, order: -1 }),
    __metadata("design:type", Object)
], CatalogScenario.prototype, "parent", void 0);
__decorate([
    jetti_middle_1.Props({ type: 'Catalog.Currency', required: true, style: { width: '100px' } }),
    __metadata("design:type", Object)
], CatalogScenario.prototype, "currency", void 0);
CatalogScenario = __decorate([
    jetti_middle_1.JDocument({
        type: 'Catalog.Scenario',
        description: 'Budget scenario',
        icon: 'fa fa-list',
        menu: 'Сценарии бюджета',
    })
], CatalogScenario);
exports.CatalogScenario = CatalogScenario;
//# sourceMappingURL=Catalog.Scenario.js.map