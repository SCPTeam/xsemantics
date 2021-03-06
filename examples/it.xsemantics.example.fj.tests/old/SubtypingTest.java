/**
 * 
 */
package it.xsemantics.example.fj.tests;

import it.xsemantics.example.fj.fj.Class;
import it.xsemantics.example.fj.fj.Type;
import it.xsemantics.example.fj.typing.FJSubtyping;
import it.xsemantics.example.fj.util.ClassFactory;
import it.xsemantics.example.fj.util.FjTypeUtils;

import org.eclipse.emf.ecore.resource.Resource;

/**
 * @author bettini
 * 
 *         Tests for subtyping
 */
public class SubtypingTest extends TestWithLoader {
	FJSubtyping fixture;

	public SubtypingTest(String name) {
		super(name);
	}

	protected void setUp() throws Exception {
		super.setUp();
		fixture = getSubtyping();
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void testBasicTypes() {
		Type intType = FjTypeUtils.createBasicType("int");
		Type intType2 = FjTypeUtils.createBasicType("int");

		assertTrue(fixture.isSubtype(intType, intType2));

		Type stringType = FjTypeUtils.createBasicType("String");

		assertFalse(fixture.isSubtype(intType, stringType));
		assertTrue(fixture.isSubtype(stringType, stringType));
	}

	public void testBasicAndClassFail() {
		Type intType = FjTypeUtils.createBasicType("int");
		Type classType = FjTypeUtils.createClassType(ClassFactory.createClass("C"));

		assertFalse(fixture.isSubtype(intType, classType));
	}

	public void testClasses() {
		// make sure to put everything in a resource
		Resource resource = createResource();

		Class c1 = ClassFactory.createClass("c1");
		resource.getContents().add(c1);
		Class c2 = ClassFactory.createClass("c2", c1);
		resource.getContents().add(c2);
		Class c3 = ClassFactory.createClass("c3", c2);
		resource.getContents().add(c3);

		resource.getContents().add(c1);
		resource.getContents().add(c2);
		resource.getContents().add(c3);

		assertTrue(fixture.isSubtype(c3, c2));
		assertTrue(fixture.isSubtype(c3, c1));
		assertTrue(fixture.isSubtype(c3, c3));

		// wrap it in types
		Type t1 = FjTypeUtils.createClassType(c1);
		Type t2 = FjTypeUtils.createClassType(c2);
		assertTrue(fixture.isSubtype(FjTypeUtils.createClassType(c3), t1));
		assertTrue(fixture.isSubtype(FjTypeUtils.createClassType(c3), t2));
		assertTrue(fixture.isSubtype(t2, t1));
	}
}
