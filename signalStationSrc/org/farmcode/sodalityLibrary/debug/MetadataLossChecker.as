package org.farmcode.sodalityLibrary.debug
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.farmcode.reflection.ReflectionUtils;
	import org.farmcode.sodality.President;
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.IPresidentAwareAdvisor;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodality.utils.AdvisorBundle;

	use namespace SodalityNamespace;

	/**
	 * The Flash Player 10 compiler introduces 'overridable' metadata, meaning that
	 * when a method is overridden any Metadata applied to the the super-method must be
	 * reapplied to the sub-method.<br/>
	 * Prior functionality allowed metadata defined on super-methods to cascade down
	 * to sub-methods.<br/>
	 * This class helps detect upgrade issues as a result of this change.
	 */
	public class MetadataLossChecker extends DynamicAdvisor implements IPresidentAwareAdvisor
	{
		public function get president():President{
			return _president;
		}
		public function set president(value:President):void{
			if(_president != value){
				if(_president){
					_president.removeEventListener(PresidentEvent.ADVISOR_ADDED,onAdvisorAdded);
					_president.removeEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
				}
				_president = value;
				if(_president){
					_president.addEventListener(PresidentEvent.ADVISOR_ADDED,onAdvisorAdded);
					_president.addEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
					for each(var advisorBundle:AdvisorBundle in _president.advisorList){
						checkObject(advisorBundle.advisor);
					}
				}
			}
		}
		
		private var _president:President;
		
		
		public function MetadataLossChecker(advisorDisplay:DisplayObject=null){
			this.advisorDisplay = advisorDisplay;
		}
		private function onAdvisorAdded(e:PresidentEvent):void{
			checkObject(e.advisor);
		}
		private function onAdviceExecute(e:PresidentEvent):void{
			checkObject(e.advice);
		}
		private function checkObject(object:Object):void{
			var nextClassPath:String = getQualifiedClassName(object);
			var classDescList:Array = [];
			var classDesc: XML;
			while(nextClassPath && nextClassPath.length && nextClassPath!="Class"){
				try{
					classDesc = ReflectionUtils.describeType(nextClassPath);
				}catch(e:Error){}
				if(classDesc){
					classDescList.unshift(classDesc);
					nextClassPath = classDesc.attribute("base");
				}else{
					break;
				}
			}
			var metadataMap:Dictionary = new Dictionary();
			for(var i:int=0; i<classDescList.length; i++){
				classDesc = classDescList[i];
				var memberList:XMLList = classDesc.descendants().(name()=="method"||name()=="variable"||name()=="accessor");
				var doWarning:Boolean = false;
				var warning:String = "";
				for each(var member:XML in memberList){
					var name:String = member.attribute("name").toString();
					if(!(metadataMap[name] is Function)){
						var metadataXML:XMLList = member.metadata;
						var metadata:Dictionary = metadataMap[name] as Dictionary;
						var memberMissing:String = "";
						if(!metadata){
							metadataMap[name] = metadata = new Dictionary();
						}else{
							for(var superMeta:String in metadata){
								var matched:XMLList = metadataXML.(attribute("name")==superMeta);
								if(!matched.length()){
									if(memberMissing.length)memberMissing += ", ";
									memberMissing += superMeta;
									doWarning = true;
								}
							}
						}
						for each(var metaXML:XML in metadataXML){
							metadata[metaXML.attribute("name").toString()] = true;
						}
						if(memberMissing.length){
							warning += "\n\tMember "+member.attribute("name")+" is missing metadata "+memberMissing;
						}
					}
				}
				if(doWarning){
					trace("WARNING: Class "+classDesc.attribute("name")+" doesn't list metadata from super Class:"+warning);
				}
			}
		}
	}
}