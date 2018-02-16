package org.eclipse.xtext.example.domainmodel.generator

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.example.domainmodel.domainmodel.Entity
import org.eclipse.xtext.example.domainmodel.domainmodel.Feature
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.example.domainmodel.domainmodel.TypeClass
import org.eclipse.xtext.example.domainmodel.domainmodel.TypeClassMember
import org.eclipse.xtext.common.types.JvmFormalParameter


/* ***
 * 
 * 
 * 
 * THIS IS CURRENTLY NOT USED
 * 
 * */

class DomainmodelGenerator extends AbstractGenerator {

	@Inject extension IQualifiedNameProvider

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
//		for (e : resource.allContents.toIterable.filter(Entity)) {
//			fsa.generateFile(e.fullyQualifiedName.toString("/") + ".java", e.compile)
//		}
		for (e : resource.allContents.toIterable.filter(TypeClass)) {
			fsa.generateFile(e.fullyQualifiedName.toString("/") + ".java", e.compile)
		}
	}

	def compile(Entity e) ''' 
		«IF e.eContainer.fullyQualifiedName !== null»
			package «e.eContainer.fullyQualifiedName»;
		«ENDIF»
		
		public class «e.name» «IF e.superType !== null
                    »extends «e.superType.fullyQualifiedName» «ENDIF»{
		    «FOR f : e.features»
		    	«f.compile»
		    «ENDFOR»
		}
	'''

	def compile(Feature f) '''
		private «f.type.fullyQualifiedName» «f.name»;
		
		public «f.type.fullyQualifiedName» get«f.name.toFirstUpper»() {
		    return «f.name»;
		}
		
		public void set«f.name.toFirstUpper»(«f.type.fullyQualifiedName» «f.name») {
		    this.«f.name» = «f.name»;
		}
	'''
	
	def compile(TypeClass t) '''
		«IF t.eContainer.fullyQualifiedName !== null»
			package «t.eContainer.fullyQualifiedName»;
		«ENDIF»
		
		public interface «t.name» {
		    «FOR m : t.members»
		    	«m.compile»
		    «ENDFOR»
		}
	'''
	
	def compile(TypeClassMember m) '''
		«m.type.toString» «FOR p : m.params»(«p.compile»)«ENDFOR»
	'''
	
	def compile(JvmFormalParameter p) {
		return p.toString
	}
}
