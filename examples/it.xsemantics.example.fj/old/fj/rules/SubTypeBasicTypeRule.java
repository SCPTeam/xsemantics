package it.xsemantics.example.fj.typesystem.fj.rules;

import it.xtypes.runtime.*;

public class SubTypeBasicTypeRule extends FJTypeSystemRule {

	protected Variable<it.xsemantics.example.fj.fj.BasicType> var_b1 = new Variable<it.xsemantics.example.fj.fj.BasicType>(
			createEClassifierType(basicPackage.getBasicType()));

	protected Variable<it.xsemantics.example.fj.fj.BasicType> var_b2 = new Variable<it.xsemantics.example.fj.fj.BasicType>(
			createEClassifierType(basicPackage.getBasicType()));

	protected TypingJudgmentEnvironment env_G = new TypingJudgmentEnvironment();

	public SubTypeBasicTypeRule() {
		this("SubTypeBasic", "|-", "<:");
	}

	public SubTypeBasicTypeRule(String ruleName, String typeJudgmentSymbol,
			String typeStatementRelation) {
		super(ruleName, typeJudgmentSymbol, typeStatementRelation);
	}

	@Override
	public Variable<it.xsemantics.example.fj.fj.BasicType> getLeft() {
		return var_b1;
	}

	@Override
	public Variable<it.xsemantics.example.fj.fj.BasicType> getRight() {
		return var_b2;
	}

	@Override
	public TypingJudgmentEnvironment getEnvironment() {
		return env_G;
	}

	@Override
	public void setEnvironment(TypingJudgmentEnvironment environment) {
		if (environment != null)
			env_G = environment;
	}

	@Override
	public RuntimeRule newInstance() {
		return new SubTypeBasicTypeRule("SubTypeBasic", "|-", "<:");
	}

	@Override
	public void applyImpl() throws RuleFailedException {

		equals(var_b1.getValue().getBasic(), var_b2.getValue().getBasic());

		// final check for variable initialization

	}

	@Override
	protected String ruleFailureMessage() {
		return stringRep(var_b1.getValue()) + " is not a subtype of "
				+ stringRep(var_b2.getValue());
	}

}
