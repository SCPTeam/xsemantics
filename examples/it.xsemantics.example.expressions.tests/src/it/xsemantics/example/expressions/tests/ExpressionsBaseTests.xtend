package it.xsemantics.example.expressions.tests

import com.google.inject.Inject
import it.xsemantics.example.expressions.ExpressionsInjectorProvider
import it.xsemantics.example.expressions.typing.ExpressionsSemantics
import it.xsemantics.runtime.RuleApplicationTrace
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Assert
import org.junit.Before
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(ExpressionsInjectorProvider))
class ExpressionsBaseTests {

	@Inject protected ExpressionsSemantics semantics
	
	protected RuleApplicationTrace trace
	
//	@BeforeClass
//	def static void setNewLine() {
//		System::setProperty("line.separator", "\n")
//	}
	
	@Before
	def void setUp() {
		trace = new RuleApplicationTrace()
	}

	def assertEqualsStrings(Object expected, Object actual) {
		Assert.assertEquals(
			("" + expected).replaceAll("\r", ""), 
			("" + actual).replaceAll("\r", "")
		)
	}
}