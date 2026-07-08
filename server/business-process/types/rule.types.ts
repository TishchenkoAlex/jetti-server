export type RuleCompareOperator =
  | '='
  | '!='
  | '>'
  | '>='
  | '<'
  | '<='
  | 'in'
  | 'notIn'
  | 'exists'
  | 'notExists';

export type Rule =
  | {
    field: string;
    op: RuleCompareOperator;
    value?: unknown;
  }
  | {
    and: Rule[];
  }
  | {
    or: Rule[];
  }
  | {
    not: Rule;
  };

