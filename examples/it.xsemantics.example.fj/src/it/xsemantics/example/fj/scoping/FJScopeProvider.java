/*
 * generated by Xtext
 */
package it.xsemantics.example.fj.scoping;

import it.xsemantics.example.fj.fj.Class;
import it.xsemantics.example.fj.fj.ClassType;
import it.xsemantics.example.fj.fj.Expression;
import it.xsemantics.example.fj.fj.Member;
import it.xsemantics.example.fj.fj.Selection;
import it.xsemantics.example.fj.typing.FjTypeSystem;
import it.xsemantics.example.fj.util.FjTypeUtils;
import it.xsemantics.runtime.RuleEnvironment;
import it.xsemantics.runtime.RuleFailedException;

import java.util.LinkedList;
import java.util.List;

import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider;

import com.google.inject.Inject;

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping on
 * how and when to use it
 * 
 */
public class FJScopeProvider extends AbstractDeclarativeScopeProvider {

	@Inject
	FjTypeSystem typeSystem;

	@Inject
	FjTypeUtils fjTypeUtils;

	// @Override
	// public IScope getScope(EObject context, EReference reference) {
	// if (reference == FjPackage.Literals.SELECTION__MESSAGE) {
	// if (context instanceof Selection) {
	// Selection selection = (Selection) context;
	// return Scopes.scopeFor(getMembers(getExpressionClass(selection
	// .getReceiver())));
	// }
	// return IScope.NULLSCOPE;
	// }
	//
	// return super.getScope(context, reference);
	// }

	public IScope scope_Member(Selection sel, EReference ref) {
		return Scopes
				.scopeFor(getMembers(getExpressionClass(sel.getReceiver())));
	}

	protected Class getExpressionClass(Expression receiver) {
		ClassType classType = typeSystem.classtype(
				environmentForExpression(receiver), receiver).getValue();
		return (classType != null ? classType.getClassref() : null);
	}

	private RuleEnvironment environmentForExpression(Expression expression) {
		return fjTypeUtils.environmentWithMappedThisAsContainingClass(expression);
	}


	public List<Member> getMembers(Class cl) {
		List<Member> allMembers = new LinkedList<Member>();
		try {
			allMembers.addAll(typeSystem.fields(cl));
			allMembers.addAll(typeSystem.methods(cl));
		} catch (RuleFailedException e) {
			// the list will be empty
		}
		return allMembers;
	}
}
