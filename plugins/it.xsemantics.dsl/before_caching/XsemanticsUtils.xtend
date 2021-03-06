package it.xsemantics.dsl.util

import com.google.common.collect.Lists
import com.google.common.collect.Sets
import com.google.inject.Inject
import it.xsemantics.dsl.typing.XsemanticsTypeSystem
import it.xsemantics.dsl.xsemantics.AuxiliaryDescription
import it.xsemantics.dsl.xsemantics.AuxiliaryFunction
import it.xsemantics.dsl.xsemantics.CheckRule
import it.xsemantics.dsl.xsemantics.ExpressionInConclusion
import it.xsemantics.dsl.xsemantics.InputParameter
import it.xsemantics.dsl.xsemantics.JudgmentDescription
import it.xsemantics.dsl.xsemantics.JudgmentParameter
import it.xsemantics.dsl.xsemantics.OutputParameter
import it.xsemantics.dsl.xsemantics.Rule
import it.xsemantics.dsl.xsemantics.RuleConclusionElement
import it.xsemantics.dsl.xsemantics.RuleInvocation
import it.xsemantics.dsl.xsemantics.RuleParameter
import it.xsemantics.dsl.xsemantics.XsemanticsSystem
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.common.types.JvmFormalParameter
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.XFeatureCall
import org.eclipse.xtext.xbase.XVariableDeclaration
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations

import static extension org.eclipse.xtext.EcoreUtil2.*
import com.google.inject.Singleton

@Singleton
class XsemanticsUtils {
	
	@Inject extension XsemanticsTypeSystem
	
	@Inject
    IJvmModelAssociations associations;
	
	def getVariableDeclarations(RuleInvocation ruleInvocation) {
		ruleInvocation.expressions.typeSelect(typeof(XVariableDeclaration))
	}
	
	def containingSystem(EObject element) {
		return EcoreUtil2::getContainerOfType(element, typeof(XsemanticsSystem))
	}
	
	def containingRule(EObject element) {
		return EcoreUtil2::getContainerOfType(element, typeof(Rule))
	}

	def containingJudgmentDescription(EObject element) {
		return EcoreUtil2::getContainerOfType(element, typeof(JudgmentDescription))
	}
	
	def List<JudgmentDescription> getJudgmentDescriptions(XsemanticsSystem ts, String judgmentSymbol, Iterable<String> relationSymbols) {
		Lists::newArrayList(filterJudgmentDescriptions(ts, judgmentSymbol, relationSymbols))
	}
	
	def filterJudgmentDescriptions(XsemanticsSystem ts, String judgmentSymbol, Iterable<String> relationSymbols) {
		ts.getJudgmentDescriptions.filterJudgmentDescriptions(judgmentSymbol, relationSymbols)
	}

	def filterJudgmentDescriptions(Iterable<JudgmentDescription> desc, String judgmentSymbol, Iterable<String> relationSymbols) {
		desc.filter
			[ it.judgmentSymbol== judgmentSymbol && 
				it.relationSymbols.elementsEqual(relationSymbols) ]
	}
	
	def judgmentDescription(Rule rule) {
		rule.judgmentDescription(rule.conclusion.judgmentSymbol, 
			rule.conclusion.relationSymbols)
	}
	
	def judgmentDescription(RuleInvocation ruleInvocation) {
		ruleInvocation.
			judgmentDescription(ruleInvocation.judgmentSymbol, 
				ruleInvocation.relationSymbols)
	}
	
	def judgmentDescription(EObject object, String judgmentSymbol, Iterable<String> relationSymbols) {
		val descriptions = Lists::newArrayList(
			object.
			containingSystem.
				allJudgments
					(judgmentSymbol, relationSymbols))
		if (descriptions.size > 0)
			descriptions.get(0)
	}
	
	def auxiliaryDescription(AuxiliaryFunction fun) {
		fun.containingSystem.
			auxiliaryDescriptions.findFirst [
				name == fun.name
			]
	}
	
	def List<Rule> rulesForJudgmentDescription(JudgmentDescription judgmentDescription) {
		Lists::newArrayList(judgmentDescription.containingSystem.
			filterRulesByJudgmentDescription
				(judgmentDescription.judgmentSymbol, judgmentDescription.relationSymbols))
	}

	def List<AuxiliaryFunction> functionsForAuxiliaryDescrition(AuxiliaryDescription aux) {
		Lists::newArrayList(aux.containingSystem.auxiliaryFunctions.
			filter[name == aux.name])
	}
	
	def filterRulesByJudgmentDescription(XsemanticsSystem ts, String judgmentSymbol, Iterable<String> relationSymbols) {
		ts.getRules.filterRulesByJudgmentDescription(judgmentSymbol,
			relationSymbols)
	}

	def filterRulesByJudgmentDescription(Iterable<Rule> rules, String judgmentSymbol, Iterable<String> relationSymbols) {
		rules.filter
			[ it.conclusion.judgmentSymbol.equals(judgmentSymbol) &&
				it.conclusion.relationSymbols.elementsEqual(relationSymbols)	]
	}
	
	def allRulesOfTheSameKind(Rule rule) {
		rule.containingSystem.allRulesOfTheSameKind(rule)
	}

	def List<Rule> allRulesOfTheSameKind(XsemanticsSystem system, Rule rule) {
		Lists::newArrayList(system.allRulesByJudgmentDescription
			(rule.conclusion.judgmentSymbol, rule.conclusion.relationSymbols))
	}
	
	def isOutputParameter(JudgmentParameter j) {
		j instanceof OutputParameter
	}
	
	def List<OutputParameter> outputJudgmentParameters(JudgmentDescription judgmentDescription) {
		judgmentDescription.getJudgmentParameters.typeSelect(typeof(OutputParameter))
	}
	
	def List<RuleConclusionElement> outputConclusionElements(Rule rule) {
		val judgmentParameters = rule.judgmentDescription.getJudgmentParameters.iterator
		// the corresponding judgmentParameter must be output
		Lists::newArrayList(
			rule.conclusion.conclusionElements.filter(
				[ judgmentParameters.next.outputParameter ]
			)
		)
	}
	
	def List<OutputParameter> outputParams(RuleInvocation ruleInvocation) {
		ruleInvocation.judgmentDescription.outputJudgmentParameters
	}
	
	def List<InputParameter> inputParams(JudgmentDescription judgmentDescription) {
		judgmentDescription.getJudgmentParameters.typeSelect(typeof(InputParameter))
	}
	
	def List<RuleParameter> inputParams(Rule rule) {
		val judgmentParameters = rule.judgmentDescription.getJudgmentParameters.iterator
		// the corresponding judgmentParameter must not be output
		Lists::newArrayList(
			rule.conclusion.conclusionElements.filter(
				[ !judgmentParameters.next.outputParameter ]
			)
		).typeSelect(typeof(RuleParameter))
	}
	
	def List<RuleParameter> inputEObjectParams(Rule rule) {
		Lists::newArrayList(rule.inputParams.filter [
			it.parameter.parameterType.isEObject(rule)
		])
	}

	def List<JvmFormalParameter> inputEObjectParams(AuxiliaryFunction aux) {
		Lists::newArrayList(aux.parameters.filter [
			parameterType.isEObject(aux)
		])
	}
	
	def isInputParam(RuleParameter ruleParameter) {
		ruleParameter.containingRule.inputParams.contains(ruleParameter)
	}

	def isOutputParam(RuleParameter ruleParameter) {
		ruleParameter.containingRule.outputParams.contains(ruleParameter)
	}
	
	def isInputParam(JvmFormalParameter jvmFormalParameter) {
		val ruleParameter = jvmFormalParameter.getContainerOfType(typeof(RuleParameter))
		if (ruleParameter != null)
			ruleParameter.inputParam
		else {
			// retrieve the AST element associated to the method
        	// created by our model inferrer
        	val sourceElement = associations.getPrimarySourceElement(jvmFormalParameter);
        	if (sourceElement instanceof RuleParameter) {
        		(sourceElement as RuleParameter).inputParam
        	} else
				false
		}
	}
	
	def List<RuleParameter> outputParams(Rule rule) {
		val judgmentDescription = rule.judgmentDescription
		if (judgmentDescription == null || judgmentDescription.judgmentParameters.empty)
			return Lists::newArrayList
		val judgmentParameters = judgmentDescription.judgmentParameters.iterator
		// the corresponding judgmentParameter must be output
		Lists::newArrayList(
			rule.conclusion.conclusionElements.filter(
				[ judgmentParameters.next.outputParameter ]
			)
		).typeSelect(typeof(RuleParameter))
	}
	
	def boolean hasOutputParams(RuleInvocation ruleInvocation) {
		!ruleInvocation.outputParams.empty
	}
	
//	def <T> void iterateIfThenElse(Iterable<T> iterable, (T)=>boolean predicate,
//		(T)=>void ifTrue, (T)=>void ifFalse) {
//		iterable.forEach() [
//			if (predicate.apply(it)) {
//				ifTrue.apply(it)
//			} else {
//				ifFalse.apply(it)
//			}
//		]		
//	}
	
	def List<ExpressionInConclusion> expressionsInConclusion(Rule rule) {
		rule.conclusion.getAllContentsOfType(typeof(ExpressionInConclusion))
	}
	
	def List<XExpression> outputArgsExpressions(RuleInvocation ruleInvocation) {
		val judgmentParameters = ruleInvocation.judgmentDescription.getJudgmentParameters.iterator
		// the corresponding judgmentParameter must be output
		Lists::newArrayList(
			ruleInvocation.expressions.filter(
				[ judgmentParameters.next.outputParameter ]
			)
		)
	}
	
	def validOutputArgExpression(XExpression xexp) {
		switch (xexp) {
			XFeatureCall : {
				val feature = xexp.feature
				if (feature instanceof JvmFormalParameter)
					return !(feature as JvmFormalParameter).inputParam
				return true;
			}
			XVariableDeclaration : {
				return xexp.writeable && xexp.right == null
			}
		}		
		return false;
	}
	
	def validInputArgExpression(XExpression ruleInvocationExpression) {
		return !(ruleInvocationExpression instanceof XVariableDeclaration);
	}
	
	def List<XExpression> inputArgsExpressions(RuleInvocation ruleInvocation) {
		val judgmentParameters = ruleInvocation.judgmentDescription.getJudgmentParameters.iterator
		// the corresponding judgmentParameter must not be output
		Lists::newArrayList(
			ruleInvocation.expressions.filter(
				[ !judgmentParameters.next.outputParameter ]
			)
		)
	}

	def allJudgments(XsemanticsSystem system) {
		Lists::newArrayList(system.judgmentDescriptions) => [
			it += system.allSuperSystemDefinitions.
				map[judgmentDescriptions].flatten
		]
	}
	
	def allJudgments(XsemanticsSystem system, String judgmentSymbol, Iterable<String> relationSymbols) {
		Lists::newArrayList(
			system.allJudgments.
				filterJudgmentDescriptions(judgmentSymbol, relationSymbols))
	}

	def allRules(XsemanticsSystem system) {
		Lists::newArrayList(system.rules) => [
			it += system.allSuperSystemDefinitions.
				map[rules].flatten
		]
	}

	def allRulesByJudgmentDescription(XsemanticsSystem ts, String judgmentSymbol, Iterable<String> relationSymbols) {
		ts.allRules.filterRulesByJudgmentDescription(judgmentSymbol,
			relationSymbols)
	}

	def allCheckRules(XsemanticsSystem system) {
		Lists::newArrayList(system.checkrules) => [
			it += system.allSuperSystemDefinitions.
				map[checkrules].flatten
		]
	}

	def allCheckRulesByName(XsemanticsSystem system, CheckRule rule) {
		Lists::newArrayList(
			system.allCheckRules.filter [ it != rule && name == rule.name ]
		)
	}

	def allSuperSystemDefinitions(XsemanticsSystem system) {
		system.
			allSuperSystemDefinitionsInternal(Sets::newHashSet)
	}

	def protected List<XsemanticsSystem> allSuperSystemDefinitionsInternal(XsemanticsSystem system, Set<XsemanticsSystem> visited) {
		if (visited.contains(system))
			return Lists::<XsemanticsSystem>newArrayList()
		
		visited.add(system)
		Lists::<XsemanticsSystem>newArrayList() => [
			val superS = system.superSystemDefinition
			if (superS != null) {
				it += superS
				it += superS.allSuperSystemDefinitionsInternal(visited)
			}
		]
	}

	def superSystemDefinition(XsemanticsSystem system) {
		system.superSystem?.originalSystemDefinition
	}

	def originalSystemDefinition(JvmTypeReference typeReference) {
		// it is the JvmType which is associated to an XsemanticsSystem
		associations.getSourceElements(typeReference.type).
			filter(typeof(XsemanticsSystem)).head
	}
	
}