import {
  BusinessProcessTaskDecision,
  BusinessProcessTransition,
} from '../types/business-process.types';
import { RuleEngine } from './rule-engine';

export class TransitionResolver {
  constructor(private readonly ruleEngine: RuleEngine = new RuleEngine()) {}

  resolve(args: {
    transitions: BusinessProcessTransition[];
    fromStepKey: string;
    decision: BusinessProcessTaskDecision;
    context: Record<string, unknown>;
  }): BusinessProcessTransition {
    const transition = args.transitions.find(item => {
      if (item.from !== args.fromStepKey || item.on !== args.decision) return false;
      return this.ruleEngine.evaluate(item.condition, args.context);
    });

    if (!transition) {
      throw new Error(`No transition found from step ${args.fromStepKey} on ${args.decision}`);
    }

    return transition;
  }
}

