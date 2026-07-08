export type AssignmentRuleType =
  | 'FIXED_USER'
  | 'ROLE'
  | 'DOCUMENT_FIELD'
  | 'RESPONSIBLE_PERSON'
  | 'AUTHOR'
  | 'MANAGER_OF_AUTHOR';

export interface AssignmentRule {
  type: AssignmentRuleType;
  userId?: string;
  role?: string;
  field?: string;
}

