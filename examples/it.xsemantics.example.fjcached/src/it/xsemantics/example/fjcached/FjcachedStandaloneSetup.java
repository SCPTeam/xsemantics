/*
* generated by Xtext
*/
package it.xsemantics.example.fjcached;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class FjcachedStandaloneSetup extends FjcachedStandaloneSetupGenerated{

	public static void doSetup() {
		new FjcachedStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

