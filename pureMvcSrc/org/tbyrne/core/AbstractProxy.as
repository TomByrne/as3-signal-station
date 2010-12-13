package org.tbyrne.core
{
	import flash.utils.Dictionary;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	import org.tbyrne.acting.actTypes.IAct;
	
	public class AbstractProxy extends Proxy
	{
		public function AbstractProxy(proxyName:String=null, data:Object=null){
			super(proxyName, data);
			
			addActHandlers();
		}
		public function destroy():void{
			facade.removeProxy(proxyName);
		}
		
		protected function addActHandlers():void{
			var actNoteMapping:Dictionary = getActNoteMapping();
			var i:String;
			var act:IAct;
			if(actNoteMapping){
				for(i in actNoteMapping){
					act = data[i] as IAct;
					act.addHandler(onActNotePerform,[actNoteMapping[i]]);
				}
			}
			var actActMapping:Dictionary = getActActMapping();
			if(actActMapping){
				for(i in actActMapping){
					act = data[i] as IAct;
					act.addHandler(onActActPerform,[actActMapping[i]]);
				}
			}
		}
		protected function getActNoteMapping():Dictionary {
			// override me with model act names mapped to notification names
			return null;
		}
		protected function getActActMapping():Dictionary {
			// override me with model act names mapped to proxy act names
			return null;
		}
		protected function onActNotePerform(... params):void{
			var notificationName:String = params[params.length-1];
			var body:*;
			params.pop();// remove notification name
			if(params[0]==data){
				params.shift();
			}
			if(params.length>0){
				body = params[0];
			}
			sendNotification(notificationName,body);
		}
		protected function onActActPerform(... params):void{
			var actName:String = params[params.length-1];
			var act:IAct = this[actName];
			params.pop(); // remove the actName from the params
			if(params[0]==data){
				params[0] = this;
			}
			act.perform.apply(null,params);
		}
	}
}