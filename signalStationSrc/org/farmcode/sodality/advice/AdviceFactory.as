package org.farmcode.sodality.advice
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.farmcode.reflection.Deliterator;
	import org.farmcode.reflection.ReflectionUtils;
	import org.farmcode.sodality.advisors.IAdvisor;
	
	public class AdviceFactory
	{
		public function getImplicitAdvice(subject:IAdvisor, subjectDescription:XML): IMemberAdvice{
			var ret:IMemberAdvice;
			if(memberNodeIsAdvice(subjectDescription)){
				ret = new PropertyAdviceProxy();
			}else if(memberNodeIsMethod(subjectDescription)){
				var className:String = subjectDescription.parameter.(@index=="2").@type;
				//ret = new MethodAdvice();
				var adviceClass:Class;
				if(className){
					adviceClass = getDefinitionByName(className) as Class;
				}else{
					adviceClass = MethodAdvice;
				}
				ret = new adviceClass();
			}
			if(ret){
				ret.subject = subject;
				ret.memberName = subjectDescription.@name;
			}
			return ret;
		}
		public function createAdvice(subject:IAdvisor, adviceDescription: XML, subjectDescription:XML): IMemberAdvice{
			var explicitType:String = adviceDescription.arg.(@key=="type").@value.toString();
			var advice:IMemberAdvice = (explicitType && explicitType.length?new (ReflectionUtils.getClassByName(explicitType))():getDefaultAdvice(subjectDescription));
			
			var arguments:Array = [];
			var argNodes:XMLList = adviceDescription.arg.(@key=="" && @key!="type");
			for each(var argNode: XML in argNodes){
				//advice[paramNode.@key] = Deliterator.deliterate(paramNode.@value.toString());
				arguments.push(Deliterator.deliterate(argNode.@value.toString()));
			}
			advice.arguments = arguments;
			
			var paramNodes:XMLList = adviceDescription.arg.(@key!="" && @key!="type");
			for each(var paramNode: XML in paramNodes){
				advice[paramNode.@key] = Deliterator.deliterate(paramNode.@value.toString());
			}
			
			advice.subject = subject;
			advice.memberName = subjectDescription.@name;
			return advice;
		}
		protected function getDefaultAdvice(subjectDescription: XML):IMemberAdvice{
			if(subjectDescription.name()=="method"){
				return new MethodAdvice();
			}else{
				return new SetPropertyAdvice();
			}
		}
		
		protected function memberNodeIsAdvice(subjectDescription: XML): Boolean{
			var isAdvice: Boolean = false;
			
			if (subjectDescription.name() == "variable")
			{
				var memberType: String = subjectDescription.attribute("type");
				var adviceInterfaceType: String = getQualifiedClassName(IAdvice);
				isAdvice = ReflectionUtils.classTypeImplements(memberType, adviceInterfaceType);
			}
			
			return isAdvice;
		}
		protected function memberNodeIsMethod(subjectDescription: XML): Boolean{
			return subjectDescription.name() == "method";
		}
	}
}