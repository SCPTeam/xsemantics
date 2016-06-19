package it.xsemantics.dsl.tests.generator

import com.google.inject.Inject
import it.xsemantics.dsl.XsemanticsInjectorProvider
import it.xsemantics.dsl.generator.XsemanticsXbaseCompiler
import it.xsemantics.dsl.xsemantics.OrExpression
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.xbase.compiler.output.ITreeAppendable
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.eclipse.xtext.EcoreUtil2.*

@InjectWith(typeof(XsemanticsInjectorProvider))
@RunWith(typeof(XtextRunner))
class XsemanticsXbaseCompilerTest extends XsemanticsGeneratorBaseTest {

	@Inject XsemanticsXbaseCompiler compiler

	@Test
	def void testXbaseCompilationOfXBlock() {
		checkCompilationOfRightExpression(
			testFiles.testRuleWithBlockExpressionInConclusion,
			"_xblockexpression",
'''

EClass _xblockexpression = null;
{
  final EClass result = EcoreFactory.eINSTANCE.createEClass();
  result.setName("MyEClass");
  _xblockexpression = (result);
}'''			
			)
	}
	
	@Test
	def void testXbaseCompilationOfXExpression() {
		checkCompilationOfRightExpression(
			testFiles.testRuleWithExpressionInConclusion,
			"_createEObject",
'''

EObject _createEObject = EcoreFactory.eINSTANCE.createEObject();'''
			)
	}
	
	@Test
	def void testRuleWithExpressionInConclusionWithParamNameAsXbaseGeneratedVariable() {
		checkCompilationOfRightExpression(
			testFiles.testRuleWithExpressionInConclusionWithInputParamNameAsXbaseGeneratedVariable,
			"_createEObject",
'''

EObject _createEObject = EcoreFactory.eINSTANCE.createEObject();'''
			)
	}
	
	@Test
	def void testWithConfiguredAppendable() {
		val appendable = createAppendable()
		// we simulate the declaration of a variable representing
		// the parameter of the rule (which would end up clashing with
		// a local variable generated by the Xbase compiler)
		appendable.declareVariable(new String(), "_createEObject")
		checkCompilationOfRightExpression(
			testFiles.testRuleWithExpressionInConclusionWithInputParamNameAsXbaseGeneratedVariable,
			"_createEObject_1",
'''

EObject _createEObject_1 = EcoreFactory.eINSTANCE.createEObject();''',
			appendable
			)
	}
	
	@Test
	def void testRuleInvokingAnotherRule() {
		checkCompilationOfPremises(
			testFiles.testRuleInvokingAnotherRule,
'''

String _string = new String();
String _firstUpper = StringExtensions.toFirstUpper("bar");
String _plus = (_string + _firstUpper);
boolean _equals = Objects.equal("foo", _plus);
/* 'foo' == new String() + "bar".toFirstUpper */
if (!_equals) {
  sneakyThrowRuleFailedException("\'foo\' == new String() + \"bar\".toFirstUpper");
}
/* G |- object.eClass : eClass */
EClass _eClass = object.eClass();
typeInternal(G, _trace_, _eClass, eClass);
/* G |- eClass : object.eClass */
EClass _eClass_1 = object.eClass();
typeInternal(G, _trace_, eClass, _eClass_1);
final EClass eC = EcoreFactory.eINSTANCE.createEClass();
eC.setName("MyEClass");
String _name = eC.getName();
boolean _equals_1 = Objects.equal(_name, "MyEClass2");
boolean _not = (!_equals_1);
/* !(eC.name == 'MyEClass2') */
if (!_not) {
  sneakyThrowRuleFailedException("!(eC.name == \'MyEClass2\')");
}
String _name_1 = eC.getName();
int _length = _name_1.length();
boolean _lessThan = (_length < 10);
/* eC.name.length < 10 */
if (!_lessThan) {
  sneakyThrowRuleFailedException("eC.name.length < 10");
}
/* eClass == eC */
if (!Objects.equal(eClass, eC)) {
  sneakyThrowRuleFailedException("eClass == eC");
}'''
			)
	}
	
	@Test
	def void testRuleInvokingAnotherRuleWithOutputParams() {
		checkCompilationOfPremises(
			testFiles.testRuleWithOutputParams,
'''

/* G |- eClass : object : feat */
Result<EObject> result = typeInternal(G, _trace_, eClass, feat);
checkAssignableTo(result.getFirst(), EObject.class);
object = (EObject) result.getFirst();
'''
			)
	}
	
	@Test
	def void testRuleInvokingAnotherRuleWithCollectionOutputParam() {
		checkCompilationOfPremises(
			testFiles.testRuleWithCollectionOutputParam,
'''

/* G |- eClass : features */
Result<List<EStructuralFeature>> result = typeInternal(G, _trace_, eClass);
checkAssignableTo(result.getFirst(), List.class);
features = (List<EStructuralFeature>) result.getFirst();
'''
			)
	}
	
	@Test
	def void testRuleWithOutputParamAsLocalVariable() {
		checkCompilationOfPremises(
			testFiles.testRuleWithOutputArgAsLocalVariable,
'''

EObject objectResult = null;
/* G |- eClass : objectResult : feat */
Result<EObject> result = typeInternal(G, _trace_, eClass, feat);
checkAssignableTo(result.getFirst(), EObject.class);
objectResult = (EObject) result.getFirst();

EObject myObject = null;
myObject = objectResult;'''
			)
	}
	
	@Test
	def void testRuleWithOutputParamsAndExplicitAssignment() {
		checkCompilationOfPremises(
			testFiles.testRuleWithOutputParamsAndExplicitAssignment,
'''

EObject objectResult = null;
/* G |- eClass : object : feat */
Result<EObject> result = typeInternal(G, _trace_, eClass, feat);
checkAssignableTo(result.getFirst(), EObject.class);
object = (EObject) result.getFirst();

object = objectResult;'''
			)
	}
	
	@Test
	def void testRuleOnlyInvokingOtherRules() {
		checkCompilationOfPremises(
			testFiles.testRuleOnlyInvokingRules,
'''

/* G |- object.eClass : eClass */
EClass _eClass = object.eClass();
typeInternal(G, _trace_, _eClass, eClass);
/* G |- eClass : object.eClass */
EClass _eClass_1 = object.eClass();
typeInternal(G, _trace_, eClass, _eClass_1);'''
			)
	}

	@Test
	def void testRuleInvocation() {
		checkCompilationOfRuleInvocation(
			testFiles.testRuleInvokingAnotherRule, 0,
'''

/* G |- object.eClass : eClass */
EClass _eClass = object.eClass();
typeInternal(G, _trace_, _eClass, eClass);'''
			)
	}
	
	@Test
	def void testRuleInvocation2() {
		checkCompilationOfRuleInvocation(
			testFiles.testRuleInvokingAnotherRule, 1,
'''

/* G |- eClass : object.eClass */
EClass _eClass = object.eClass();
typeInternal(G, _trace_, eClass, _eClass);'''
			)
	}
	
	@Test
	def void testOrExpression() {
		checkCompilationOfOr(
			testFiles.testOrExpression, 0,
'''

/* eClass.name == 'foo' or object.eClass.name == 'bar' */
{
  RuleFailedException previousFailure = null;
  try {
    String _name = eClass.getName();
    boolean _equals = Objects.equal(_name, "foo");
    /* eClass.name == 'foo' */
    if (!_equals) {
      sneakyThrowRuleFailedException("eClass.name == \'foo\'");
    }
  } catch (Exception e) {
    previousFailure = extractRuleFailedException(e);
    EClass _eClass = object.eClass();
    String _name_1 = _eClass.getName();
    boolean _equals_1 = Objects.equal(_name_1, "bar");
    /* object.eClass.name == 'bar' */
    if (!_equals_1) {
      sneakyThrowRuleFailedException("object.eClass.name == \'bar\'");
    }
  }
}'''
			)
	}
	
	@Test
	def void testOrExpression2() {
		checkCompilationOfOr(
			testFiles.testOrExpression2, 0,
'''

/* eClass.name == 'foo' or object.eClass.name == 'bar' */
{
  RuleFailedException previousFailure = null;
  try {
    String _name = eClass.getName();
    boolean _equals = Objects.equal(_name, "foo");
    /* eClass.name == 'foo' */
    if (!_equals) {
      sneakyThrowRuleFailedException("eClass.name == \'foo\'");
    }
  } catch (Exception e) {
    previousFailure = extractRuleFailedException(e);
    EClass _eClass = object.eClass();
    String _name_1 = _eClass.getName();
    boolean _equals_1 = Objects.equal(_name_1, "bar");
    /* object.eClass.name == 'bar' */
    if (!_equals_1) {
      sneakyThrowRuleFailedException("object.eClass.name == \'bar\'");
    }
  }
}'''
			)
	}

	@Test
	def void testOrExpressionWithRuleInvocations() {
		checkCompilationOfOr(
			testFiles.testOrExpressionWithRuleInvocations, 0,
'''

/* {eClass.name == 'foo' G |- object.eClass : eClass} or {G |- object.eClass : eClass object.eClass.name == 'bar'} */
{
  RuleFailedException previousFailure = null;
  try {
    String _name = eClass.getName();
    boolean _equals = Objects.equal(_name, "foo");
    /* eClass.name == 'foo' */
    if (!_equals) {
      sneakyThrowRuleFailedException("eClass.name == \'foo\'");
    }
    /* G |- object.eClass : eClass */
    EClass _eClass = object.eClass();
    typeInternal(G, _trace_, _eClass, eClass);
  } catch (Exception e) {
    previousFailure = extractRuleFailedException(e);
    /* G |- object.eClass : eClass */
    EClass _eClass_1 = object.eClass();
    typeInternal(G, _trace_, _eClass_1, eClass);
    EClass _eClass_2 = object.eClass();
    String _name_1 = _eClass_2.getName();
    /* object.eClass.name == 'bar' */
    if (!Objects.equal(_name_1, "bar")) {
      sneakyThrowRuleFailedException("object.eClass.name == \'bar\'");
    }
  }
}'''
			)
	}

	@Test
	def void testOrExpressionWithRuleInvocations2() {
		checkCompilationOfOr(
			testFiles.testOrExpressionWithRuleInvocations2, 0,
'''

/* G |- object.eClass : eClass or G |- object.eClass : eClass */
{
  RuleFailedException previousFailure = null;
  try {
    /* G |- object.eClass : eClass */
    EClass _eClass = object.eClass();
    typeInternal(G, _trace_, _eClass, eClass);
  } catch (Exception e) {
    previousFailure = extractRuleFailedException(e);
    /* G |- object.eClass : eClass */
    EClass _eClass_1 = object.eClass();
    typeInternal(G, _trace_, _eClass_1, eClass);
  }
}'''
			)
	}
	
	@Test
	def void testOrExpressionWithManyBranches() {
		checkCompilationOfOr(
			testFiles.testOrExpressionWithManyBranches, 0,
'''

/* G |- object.eClass : eClass or G |- object.eClass : eClass or {G |- object.eClass : eClass object.eClass.name == 'bar'} or object.eClass.name == 'bar' */
{
  RuleFailedException previousFailure = null;
  try {
    /* G |- object.eClass : eClass */
    EClass _eClass = object.eClass();
    typeInternal(G, _trace_, _eClass, eClass);
  } catch (Exception e) {
    previousFailure = extractRuleFailedException(e);
    /* G |- object.eClass : eClass or {G |- object.eClass : eClass object.eClass.name == 'bar'} or object.eClass.name == 'bar' */
    {
      try {
        /* G |- object.eClass : eClass */
        EClass _eClass_1 = object.eClass();
        typeInternal(G, _trace_, _eClass_1, eClass);
      } catch (Exception e_1) {
        previousFailure = extractRuleFailedException(e_1);
        /* {G |- object.eClass : eClass object.eClass.name == 'bar'} or object.eClass.name == 'bar' */
        {
          try {
            /* G |- object.eClass : eClass */
            EClass _eClass_2 = object.eClass();
            typeInternal(G, _trace_, _eClass_2, eClass);
            EClass _eClass_3 = object.eClass();
            String _name = _eClass_3.getName();
            /* object.eClass.name == 'bar' */
            if (!Objects.equal(_name, "bar")) {
              sneakyThrowRuleFailedException("object.eClass.name == \'bar\'");
            }
          } catch (Exception e_2) {
            previousFailure = extractRuleFailedException(e_2);
            EClass _eClass_4 = object.eClass();
            String _name_1 = _eClass_4.getName();
            boolean _equals = Objects.equal(_name_1, "bar");
            /* object.eClass.name == 'bar' */
            if (!_equals) {
              sneakyThrowRuleFailedException("object.eClass.name == \'bar\'");
            }
          }
        }
      }
    }
  }
}'''
			)
	}
	
	@Test
	def void testRuleInvocationResultVariable() {
		val appendable = createAppendable()
		checkRuleInvocationVariable(
			testFiles.testRuleInvokingAnotherRule, 0, appendable, "result")
		checkRuleInvocationVariable(
			testFiles.testRuleInvokingAnotherRule, 1, appendable, "result_1")
	}
	
	@Test
	def void testFeatureCallExpressions() {
		checkCompilationOfAllPremises(
			testFiles.testRuleWithFeatureCalls,
'''

/* 'foo' == new String() || 'bar' == new String() */
if (!(Objects.equal("foo", new String()) || Objects.equal("bar", new String()))) {
  sneakyThrowRuleFailedException("\'foo\' == new String() || \'bar\' == new String()");
}
/* 'foo' == new String() && 'bar' == new String() */
if (!(Objects.equal("foo", new String()) && Objects.equal("bar", new String()))) {
  sneakyThrowRuleFailedException("\'foo\' == new String() && \'bar\' == new String()");
}
String _string = new String();
String _firstUpper = StringExtensions.toFirstUpper("bar");
String _plus = (_string + _firstUpper);
boolean _equals = Objects.equal("foo", _plus);
/* 'foo' == new String() + 'bar'.toFirstUpper */
if (!_equals) {
  sneakyThrowRuleFailedException("\'foo\' == new String() + \'bar\'.toFirstUpper");
}
String _string_1 = new String();
String _firstUpper_1 = StringExtensions.toFirstUpper("bar");
String _plus_1 = (_string_1 + _firstUpper_1);
boolean _notEquals = (!Objects.equal("foo", _plus_1));
/* 'foo' != new String() + 'bar'.toFirstUpper */
if (!_notEquals) {
  sneakyThrowRuleFailedException("\'foo\' != new String() + \'bar\'.toFirstUpper");
}
String _string_2 = new String();
String _firstUpper_2 = StringExtensions.toFirstUpper("bar");
final String temp = (_string_2 + _firstUpper_2);
boolean _contains = "foo".contains("f");
/* 'foo'.contains('f') */
if (!_contains) {
  sneakyThrowRuleFailedException("\'foo\'.contains(\'f\')");
}
"foo".concat("f");
boolean _contains_1 = "foo".contains("f");
boolean _not = (!_contains_1);
/* !('foo'.contains('f')) */
if (!_not) {
  sneakyThrowRuleFailedException("!(\'foo\'.contains(\'f\'))");
}
final EClass eC = EcoreFactory.eINSTANCE.createEClass();'''
			)
	}
	
	@Test
	def void testThrowRuleFailedException() {
		val a = createAppendable
		compiler.throwNewRuleFailedException(getXAbstractFeatureCall(0), a)
		assertEqualsStrings('''sneakyThrowRuleFailedException("\'foo\' == new String() || \'bar\' == new String()");''', 
			a.toString
		)
	}
	
	@Test
	def void testEmptyEnvironmentSpecification() {
		checkCompilationOfEnvironmentSpecfication(
			testFiles.testEmptyEnvironment,
			"emptyEnvironment()"
		)
	}
	
	@Test
	def void testEnvironmentReference() {
		checkCompilationOfEnvironmentSpecfication(
			testFiles.testRuleOnlyInvokingRules,
			"G"
		)
	}
	
	@Test
	def void testSingleEnvironmentMapping() {
		checkCompilationOfEnvironmentSpecfication(
			testFiles.testSingleEnvironmentMapping,
			'''environmentEntry("this", object)'''
		)
	}
	
	@Test
	def void testEnvironmentComposition() {
		checkCompilationOfEnvironmentSpecfication(
			testFiles.testEnvironmentCompositionWithMapping,
'''
environmentComposition(
  G, environmentEntry("this", object)
)'''
		)
	}
	
	@Test
	def void testRuleInvocationEnvironmentComposition() {
		checkCompilationOfRuleInvocation(
			testFiles.testEnvironmentComposition2, 0,
'''

/* empty, G, empty, G |- object.eClass : eClass */
EClass _eClass = object.eClass();
typeInternal(environmentComposition(
  emptyEnvironment(), environmentComposition(
    G, environmentComposition(
      emptyEnvironment(), G
    )
  )
), _trace_, _eClass, eClass);'''
		)
	}
	
	@Test
	def void testRuleInvocationEnvironmentComposition2() {
		checkCompilationOfRuleInvocation(
			testFiles.testEnvironmentMapping2, 0,
'''

/* G, 'this' <- object, object <- EcoreFactory::eINSTANCE.createEClass() |- object.eClass : eClass */
EClass _eClass = object.eClass();
EClass _createEClass = EcoreFactory.eINSTANCE.createEClass();
typeInternal(environmentComposition(
  G, environmentComposition(
    environmentEntry("this", object), environmentEntry(object, _createEClass)
  )
), _trace_, _eClass, eClass);'''
		)
	}
	
	@Test
	def void testForFail() {
		checkCompilationOfAllPremises(
			testFiles.testForFail,
'''

/* empty |- obj : eClass */
Result<EClass> result = typeInternal(emptyEnvironment(), _trace_, obj);
checkAssignableTo(result.getFirst(), EClass.class);
eClass = (EClass) result.getFirst();

/* fail */
throwForExplicitFail();'''
			)
	}
	
	@Test
	def void testForFailWithErrorSpecification() {
		checkCompilationOfAllPremises(
			testFiles.testForFailWithErrorSpecification,
'''

/* empty |- obj : eClass */
Result<EClass> result = typeInternal(emptyEnvironment(), _trace_, obj);
checkAssignableTo(result.getFirst(), EClass.class);
eClass = (EClass) result.getFirst();

/* fail error "this is the error" source obj */
String error = "this is the error";
EObject source = obj;
throwForExplicitFail(error, new ErrorInformation(source, null));'''
			)
	}

	@Test
	def void testForClosures() {
		checkCompilationOfAllPremises(
			testFiles.testForClosures,
'''

EList<EStructuralFeature> _eStructuralFeatures = eClass.getEStructuralFeatures();
final Function1<EStructuralFeature, Boolean> _function = new Function1<EStructuralFeature, Boolean>() {
  public Boolean apply(final EStructuralFeature it) {
    String _name = it.getName();
    return Boolean.valueOf((!Objects.equal(_name, "foo")));
  }
};
boolean _forall = IterableExtensions.<EStructuralFeature>forall(_eStructuralFeatures, _function);
/* eClass.EStructuralFeatures.forall [ it.name != 'foo' ] */
if (!_forall) {
  sneakyThrowRuleFailedException("eClass.EStructuralFeatures.forall [ it.name != \'foo\' ]");
}
EList<EStructuralFeature> _eStructuralFeatures_1 = eClass.getEStructuralFeatures();
final Function1<EStructuralFeature, Boolean> _function_1 = new Function1<EStructuralFeature, Boolean>() {
  public Boolean apply(final EStructuralFeature it) {
    String _name = it.getName();
    /* it.name != 'foo' */
    if (!Boolean.valueOf((!Objects.equal(_name, "foo")))) {
      sneakyThrowRuleFailedException("it.name != \'foo\'");
    }
    return Boolean.valueOf((!Objects.equal(_name, "foo")));
  }
};
boolean _forall_1 = IterableExtensions.<EStructuralFeature>forall(_eStructuralFeatures_1, _function_1);
/* eClass.EStructuralFeatures.forall [ { it.name != 'foo' } ] */
if (!_forall_1) {
  sneakyThrowRuleFailedException("eClass.EStructuralFeatures.forall [ { it.name != \'foo\' } ]");
}
EList<EStructuralFeature> _eStructuralFeatures_2 = eClass.getEStructuralFeatures();
final Procedure1<EStructuralFeature> _function_2 = new Procedure1<EStructuralFeature>() {
  public void apply(final EStructuralFeature it) {
    /* G ||- it */
    uselessInternal(G, _trace_, it);
  }
};
IterableExtensions.<EStructuralFeature>forEach(_eStructuralFeatures_2, _function_2);
EList<EStructuralFeature> _eStructuralFeatures_3 = eClass.getEStructuralFeatures();
EStructuralFeature _get = _eStructuralFeatures_3.get(0);
String _name = _get.getName();
/* eClass.EStructuralFeatures.get(0).name != 'foo' */
if (!(!Objects.equal(_name, "foo"))) {
  sneakyThrowRuleFailedException("eClass.EStructuralFeatures.get(0).name != \'foo\'");
}'''
			)
	}
	
	@Test
	def void testForClosureWithExpressionWithNoSideEffect() {
		checkCompilationOfAllPremises(
			testFiles.testForClosureWithExpressionWithNoSideEffect,
'''

EList<EStructuralFeature> _eStructuralFeatures = eClass.getEStructuralFeatures();
final Procedure1<EStructuralFeature> _function = new Procedure1<EStructuralFeature>() {
  public void apply(final EStructuralFeature it) {
    String _name = it.getName();
    /* it.name != "foo" */
    if (!(!Objects.equal(_name, "foo"))) {
      sneakyThrowRuleFailedException("it.name != \"foo\"");
    }
  }
};
IterableExtensions.<EStructuralFeature>forEach(_eStructuralFeatures, _function);
EList<EStructuralFeature> _eStructuralFeatures_1 = eClass.getEStructuralFeatures();
final Procedure1<EStructuralFeature> _function_1 = new Procedure1<EStructuralFeature>() {
  public void apply(final EStructuralFeature it) {
    String _name = it.getName();
    /* (!Objects.equal(_name, "foo")); */
  }
};
IterableExtensions.<EStructuralFeature>forEach(_eStructuralFeatures_1, _function_1);
EList<EStructuralFeature> _eStructuralFeatures_2 = eClass.getEStructuralFeatures();
final Procedure1<EStructuralFeature> _function_2 = new Procedure1<EStructuralFeature>() {
  public void apply(final EStructuralFeature it) {
    EList<EStructuralFeature> _eStructuralFeatures = eClass.getEStructuralFeatures();
    final Procedure1<EStructuralFeature> _function = new Procedure1<EStructuralFeature>() {
      public void apply(final EStructuralFeature it) {
        String _name = it.getName();
        /* (!Objects.equal(_name, "foo")); */
      }
    };
    IterableExtensions.<EStructuralFeature>forEach(_eStructuralFeatures, _function);
  }
};
IterableExtensions.<EStructuralFeature>forEach(_eStructuralFeatures_2, _function_2);'''
			)
	}

	@Test
	def void testRuleWithBooleanExpressionsWithNoSideEffectInFor() {
		checkCompilationOfAllPremises(
			testFiles.testRuleWithBooleanExpressionsWithNoSideEffectInFor,
'''

EList<EStructuralFeature> _eAllStructuralFeatures = eClass.getEAllStructuralFeatures();
for (final EStructuralFeature s : _eAllStructuralFeatures) {
  String _name = s.getName();
  /* s.name != 'foo' */
  if (!(!Objects.equal(_name, "foo"))) {
    sneakyThrowRuleFailedException("s.name != \'foo\'");
  }
}'''
			)
	}

	@Test
	def void testRuleWithBooleanExpressionsWithNoSideEffectInIf() {
		checkCompilationOfAllPremises(
			testFiles.testRuleWithBooleanExpressionsWithNoSideEffectInIf,
		'''
		
		boolean _notEquals = (!Objects.equal(eClass, null));
		if (_notEquals) {
		  /* object != 'foo' */
		  if (!(!Objects.equal(object, "foo"))) {
		    sneakyThrowRuleFailedException("object != \'foo\'");
		  }
		}'''
			)
	}

	@Test
	def void testRuleInvocationWithVarDeclarationAsOutputArg() {
		checkCompilationOfRuleInvocation(
			testFiles.testVariableDeclarationAsOutputArgument, 0,
'''

/* G |- o : var EClass e */
EClass e = null;
Result<EClass> result = typeInternal(G, _trace_, o);
checkAssignableTo(result.getFirst(), EClass.class);
e = (EClass) result.getFirst();
'''
			)
	}

	@Test
	def void testRuleInvocationIsBooleanInClosures() {
		checkCompilationOfPremises(
			testFiles.testRuleInvocationIsBooleanInClosures,
'''

EList<EStructuralFeature> _eStructuralFeatures = eClass.getEStructuralFeatures();
final Function1<EStructuralFeature, Boolean> _function = new Function1<EStructuralFeature, Boolean>() {
  public Boolean apply(final EStructuralFeature it) {
    /* G ||- it */
    boolean _ruleinvocation = uselessSucceeded(G, _trace_, it);
    return Boolean.valueOf(_ruleinvocation);
  }
};
/* eClass.EStructuralFeatures.forall [ G ||- it ] */
if (!IterableExtensions.<EStructuralFeature>forall(_eStructuralFeatures, _function)) {
  sneakyThrowRuleFailedException("eClass.EStructuralFeatures.forall [ G ||- it ]");
}'''
			)
	}

	@Test
	def void testRuleInvocationIsBooleanInIfExpression() {
		checkCompilationOfPremises(
			testFiles.testRuleInvocationIsBooleanInIfExpression,
'''

/* G ||- eClass.EStructuralFeatures.head */
EList<EStructuralFeature> _eStructuralFeatures = eClass.getEStructuralFeatures();
EStructuralFeature _head = IterableExtensions.<EStructuralFeature>head(_eStructuralFeatures);
boolean _ruleinvocation = uselessSucceeded(G, _trace_, _head);
if (_ruleinvocation) {
  InputOutput.<String>println("OK");
}'''
			)
	}

	@Test
	def void testRuleInvocationsAsBooleanExpressions() {
		checkCompilationOfPremises(
			testFiles.testRuleInvocationsAsBooleanExpressions,
'''

final EList<EStructuralFeature> features = eClass.getEStructuralFeatures();
final Function1<EStructuralFeature, Boolean> _function = new Function1<EStructuralFeature, Boolean>() {
  public Boolean apply(final EStructuralFeature it) {
    boolean _or = false;
    /* G ||- it */
    boolean _ruleinvocation = uselessSucceeded(G, _trace_, it);
    if (_ruleinvocation) {
      _or = true;
    } else {
      boolean _notEquals = (!Objects.equal(eClass, null));
      _or = _notEquals;
    }
    return Boolean.valueOf(_or);
  }
};
boolean _forall = IterableExtensions.<EStructuralFeature>forall(features, _function);
/* features.forall [ {G ||- it} || eClass != null ] */
if (!_forall) {
  sneakyThrowRuleFailedException("features.forall [ {G ||- it} || eClass != null ]");
}
final Function1<EStructuralFeature, Boolean> _function_1 = new Function1<EStructuralFeature, Boolean>() {
  public Boolean apply(final EStructuralFeature it) {
    boolean _xblockexpression = false;
    {
      InputOutput.<String>println("testing");
      /* G ||- it */
      boolean _ruleinvocation = uselessSucceeded(G, _trace_, it);
      _xblockexpression = _ruleinvocation;
    }
    return Boolean.valueOf(_xblockexpression);
  }
};
/* features.forall [ println("testing") G ||- it ] */
if (!IterableExtensions.<EStructuralFeature>forall(features, _function_1)) {
  sneakyThrowRuleFailedException("features.forall [ println(\"testing\") G ||- it ]");
}'''
			)
	}

	def void checkCompilationOfRightExpression(CharSequence inputCode, 
		String expectedExpName, CharSequence expected) {
		checkCompilationOfRightExpression(inputCode, expectedExpName, expected,
			createAppendable())
	}
	
	def void checkCompilationOfRightExpression(CharSequence inputCode, 
		String expectedExpName, CharSequence expected, ITreeAppendable appendable) {
		val xexp = inputCode.
			firstRule.conclusion.conclusionElements.get(1).ruleExpression.expression
		compiler.toJavaStatement(xexp, appendable, true)
		assertEqualsStrings(expected, appendable)
		val expName = appendable.getName(xexp)
		assertEqualsStrings(expectedExpName, expName)
	}
	
	def void checkCompilationOfPremises(CharSequence inputCode, 
		CharSequence expected) {
		val rule = inputCode.firstRule
		val xexp = rule.rulePremisesAsBlock
		val appendable = rule.createAppendable
		compiler.toJavaStatement(xexp, appendable, false)
		assertEqualsStrings(expected, appendable)
	}
	
	def void checkCompilationOfPremisesOfCheckRule(CharSequence inputCode, 
		CharSequence expected) {
		val xexp = inputCode.
			firstCheckRule.rulePremisesAsBlock
		val appendable = createAppendable
		compiler.toJavaStatement(xexp, appendable, false)
		assertEqualsStrings(expected, appendable)
	}

	def void checkCompilationOfRuleInvocation(CharSequence inputCode, int index,
		CharSequence expected) {
		val rule = inputCode.firstRule
		val xexp = rule.ruleInvocations.get(index)
		val result = rule.createAppendable
		compiler.toJavaStatement(xexp, result, false)
		assertEqualsStrings(expected, result)
	}
	
	def void checkCompilationOfOr(CharSequence inputCode, int index,
		CharSequence expected) {
		val rule = inputCode.firstRule
		val xexp = rule.ors.get(index)
		val result = rule.createAppendable
		compiler.toJavaStatement(xexp, result, false)
		assertEqualsStrings(expected, result)
	}
	
	def void checkRuleInvocationVariable(CharSequence inputCode, int index,
		ITreeAppendable appendable, String expectedVariableName) {
		val xexp = inputCode.
			parseAndAssertNoError.ruleInvocations.get(index)
		val variable = compiler.declareResultVariable(xexp, appendable)
		assertEqualsStrings(expectedVariableName, variable)
	}
	
	def void checkCompilationOfAllPremises(CharSequence inputCode, CharSequence expected) {
		val rule = inputCode.firstRule
		val result = rule.createJvmModelGeneratorConfiguredAppendable
		val xexp = rule.rulePremisesAsBlock
		compiler.toJavaStatement(xexp, result, false)
		assertEqualsStrings(expected, result)
	}
	
	def void checkCompilationOfAllPremisesOfCheckRule(CharSequence inputCode, CharSequence expected) {
		val rule = inputCode.firstCheckRule
		val result = rule.createAppendable
		val xexp = rule.rulePremisesAsBlock
		compiler.toJavaStatement(xexp, result, false)
		assertEqualsStrings(expected, result)
	}
	
	def void checkCompilationOfXExpression(CharSequence inputCode, int index,
		CharSequence expected) {
		val rule = inputCode.firstRule
		val xexp = rule.rulePremises.get(index)
		val result = rule.createAppendable
		compiler.toJavaStatement(xexp, result, false)
		assertEqualsStrings(expected, result)
	}
	
	def void checkCompilationOfEnvironmentSpecfication(CharSequence inputCode, CharSequence expected) {
		val rule = inputCode.firstRule
		val xexp = rule.environmentSpecificationOfRuleInvocation
		val result = rule.createAppendable
		compiler.generateEnvironmentSpecificationAsExpression(xexp, result)
		assertEqualsStrings(expected, result)
	}

	def private getOrs(EObject element) {
		element.getAllContentsOfType(typeof(OrExpression))
	}

}