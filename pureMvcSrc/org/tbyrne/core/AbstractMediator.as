package org.tbyrne.core
{
	import flash.utils.Dictionary;
	
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.tbyrne.acting.actTypes.IAct;

	public class AbstractMediator extends Mediator
	{
		public function AbstractMediator(mediatorName:String=null, viewComponent:Object=null){
			super(mediatorName, viewComponent);
			
			addActHandlers();
		}
		protected function addActHandlers():void{
			var actHandlerMapping:Dictionary = getActHandlerMapping();
			if(actHandlerMapping){
				for(var i:String in actHandlerMapping){
					var act:IAct = viewComponent[i] as IAct;
					act.addHandler(onActPerform,[actHandlerMapping[i]]);
				}
			}
		}
		protected function getActHandlerMapping():Dictionary {
			// override me with act names mapped to notification names
			return null;
		}
		protected function onActPerform(from:Object, ... params):void{
			var notificationName:String = params[params.length-1];
			var body:*;
			if(params.length>1){
				body = params[0];
			}
			sendNotification(notificationName,body);
		}
	}
}