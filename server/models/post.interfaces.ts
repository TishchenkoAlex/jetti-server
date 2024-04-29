import { Ref, RegisterAccount, RegisterAccumulation, RegisterInfo } from 'jetti-middle';

export interface PostResult {
  Account: RegisterAccount[];
  Accumulation: RegisterAccumulation[];
  Info: RegisterInfo[];
}
export interface RegisterMovement {
  date: Date;
  type: string;
  company: Ref;
  document: string;
  data: string;
}

export interface AccumulationMovement extends RegisterMovement {
  id: string;
  parent: null;
  calculated: number;
  kind: number;
}

export interface InfoMovement extends RegisterMovement { }

export interface IRegistersMovements {
  accumulation: AccumulationMovement[],
  info: InfoMovement[]
}
