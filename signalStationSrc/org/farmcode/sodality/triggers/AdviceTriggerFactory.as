package org.farmcode.sodality.triggers
{
	import org.farmcode.reflection.Deliterator;
	import org.farmcode.reflection.ReflectionUtils;
	
	public class AdviceTriggerFactory
	{
		protected var defaultTriggerClass: Class;
		
		public function AdviceTriggerFactory()
		{
			this.defaultTriggerClass = AdviceClassTrigger;
		}
		
		public function createAdviceTrigger(triggerDescription:XML, subjectDescription:XML):IMemberAdviceTrigger
		{
			var explicitType:String = triggerDescription.arg.(@key=="type").@value.toString();
			var type:Class = (explicitType && explicitType.length?ReflectionUtils.getClassByName(explicitType):this.defaultTriggerClass);
			var trigger:IMemberAdviceTrigger = new type();
			
			var cast:IAdviceClassTrigger = (trigger as IAdviceClassTrigger);
			if(cast){
				cast.adviceClassName = subjectDescription.parameter.(@index=="1").@type;
			}
			
			var paramNodes:XMLList = triggerDescription.arg.(@key!="" && @key!="type"); // ignore variables without names
			for each(var paramNode: XML in paramNodes){
				trigger[paramNode.@key] = Deliterator.deliterate(paramNode.@value.toString());
			}
			return trigger;
		}
	}
}