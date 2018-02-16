package org.eclipse.xtext.example.domainmodel.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.example.domainmodel.domainmodel.Entity
import org.eclipse.xtext.example.domainmodel.domainmodel.Operation
import org.eclipse.xtext.example.domainmodel.domainmodel.Property
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import org.eclipse.xtext.example.domainmodel.domainmodel.TypeClass
import org.eclipse.xtext.example.domainmodel.domainmodel.TypeClassInstance
import org.eclipse.xtext.common.types.TypesFactory

class DomainmodelJvmModelInferrer extends AbstractModelInferrer {

	@Inject extension JvmTypesBuilder
	@Inject extension IQualifiedNameProvider

	def dispatch infer(TypeClass typeClass, extension IJvmDeclaredTypeAcceptor acceptor, boolean prelinkingPhase) {
		accept(typeClass.toInterface(typeClass.fullyQualifiedName.toString, null)) [
			val param = TypesFactory.eINSTANCE.createJvmTypeParameter()
			param.name = typeClass.typeParameter
			typeParameters += param
			documentation = typeClass.documentation

			// now let's go over the features
			for (m : typeClass.members) {
				members += m.toMethod(m.name, m.type ?: inferredType) [
					documentation = m.documentation
					abstract = true
					val tp = typeRef(typeClass.typeParameter)
					parameters += m.toParameter("self", tp)
		
					for (p : m.params) {
						parameters += p.toParameter(p.name, p.parameterType)
					}
				]
			}

		]
	}
	
	def dispatch infer(TypeClassInstance entity, extension IJvmDeclaredTypeAcceptor acceptor, boolean prelinkingPhase) {
		accept(entity.toClass(entity.fullyQualifiedName+"$tc$"+entity.typeClass.name+"$"+entity.typeParameter.simpleName)) [
			documentation = entity.documentation
			superTypes += typeRef(entity.typeClass.fullyQualifiedName.toString, typeRef(entity.typeParameter.qualifiedName))

			// let's add a default constructor
			members += entity.toConstructor[]


			// now let's go over the features
			for (f : entity.members) {

				members += f.toMethod(f.name, f.type ?: inferredType) [
					documentation = f.documentation
					val pp = f.toParameter("self", entity.typeParameter)
					parameters += pp
					for (p : f.params) {
						parameters += p.toParameter(p.name, p.parameterType)
					}
					// here the body is implemented using a user expression.
					// Note that by doing this we set the expression into the context of this method, 
					// The parameters, 'this' and all the members of this method will be visible for the expression. 
					body = f.body
				]
		
			}

		]
	}

	def dispatch infer(Entity entity, extension IJvmDeclaredTypeAcceptor acceptor, boolean prelinkingPhase) {
		accept(entity.toClass(entity.fullyQualifiedName)) [
			documentation = entity.documentation
			if (entity.superType !== null)
				superTypes += entity.superType.cloneWithProxies

			// let's add a default constructor
			members += entity.toConstructor[]

			// now let's go over the features
			for (f : entity.features) {
				switch f {
					// for properties we create a field, a getter and a setter
					Property: {
						val field = f.toField(f.name, f.type)
						members += field
						members += f.toGetter(f.name, f.type)
						members += f.toSetter(f.name, f.type)
					}
					// operations are mapped to methods
					Operation: {
						members += f.toMethod(f.name, f.type ?: inferredType) [
							documentation = f.documentation
							for (p : f.params) {
								parameters += p.toParameter(p.name, p.parameterType)
							}
							// here the body is implemented using a user expression.
							// Note that by doing this we set the expression into the context of this method, 
							// The parameters, 'this' and all the members of this method will be visible for the expression. 
							body = f.body
						]
					}
				}
			}


		]
	}

}
