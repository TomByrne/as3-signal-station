package org.farmcode.acting.metadata
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.AsynchronousAct;
	import org.farmcode.acting.metadata.ruleTypes.IUniversalClassRule;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	import org.farmcode.compiler.MetadataConfirmer;
	import org.farmcode.reflection.Deliterator;
	import org.farmcode.reflection.ReflectionUtils;
	import org.farmcode.utils.ObjectUtils;

	public class MetadataActorRegistry
	{
		private static const REQUIRED_META_TAGS: Array = ["ActRule"];
		private static const DEFAULT_RULE_PACKAGE: String = "org.farmcode.acting.universal.rules.";
		private static const PROPERTY_MATCHER:RegExp = /\{([\w\.]+)\}/;
		
		private static var actMap:Dictionary = new Dictionary();
		
		public static function addActor(actor:Object, scopeDisplay:DisplayObject):void{
			if(!actMap[actor]){
				var classDesc: XML = ReflectionUtils.describeType(actor);
				var memberList: XMLList = classDesc.descendants().(name()=="method"||name()=="variable"||name()=="accessor");
				var acts:Array = [];
				
				var act:MetadataAct;
				var rule:IUniversalRule;
				for each(var memberNode:XML in memberList){
					var metaDataXML: XMLList = memberNode.metadata;
					var tot:Number = metaDataXML.length();
					act = null;
					
					for(var i:int=0; i<tot; ++i){
						var metaData:XML = metaDataXML[i];
						var metaName:String = metaData.attribute("name");
						switch(metaName){
							case "ActRule":
								if(!act){
									act = new MetadataAct(actor[memberNode.@name]);
									act.scopeDisplay = scopeDisplay;
									act.doAsynchronous = (memberNode.parameter.length()>1);
									act.passExecution = (memberNode.parameter.length()>2);
									acts.push(act);
								}
								act.addUniversalRule(createRule(metaData,memberNode,act.doAsynchronous,actor));
								break;
						}
					}
				}
				actMap[actor] = acts;
			}else{
				throw new Error("Actor already registered");
			}
		}
		public static function removeActor(actor:Object):void{
			var acts:Array = actMap[actor];
			if(acts){
				var tot:int = acts.length;
				for(var i:int=0; i<tot; ++i){
					var act:MetadataAct = acts[i];
					act.scopeDisplay = null;
					act.removeAllUniversalRules();
				}
				delete actMap[actor];
			}else{
				throw new Error("Actor not registered");
			}
		}
		protected static function createRule(triggerDescription:XML, subjectDescription:XML, asynchronous:Boolean, actor:Object):IUniversalRule
		{
			var paramNodes:XMLList = triggerDescription.arg;
			var explicitType:String;
			var props:Dictionary;
			var key:String;
			var value:String;
			for each(var paramNode: XML in paramNodes){
				key = paramNode.@key;
				value = paramNode.@value;
				if(!explicitType && key==""){
					explicitType = value;
				}else if(key!="" && value!=""){
					if(!props)props = new Dictionary();
					props[key] = value;
				}
			}
			
			var type:Class;
			if(explicitType && explicitType.length){
				if(explicitType.indexOf(".")==-1)explicitType = DEFAULT_RULE_PACKAGE+explicitType;
				type = ReflectionUtils.getClassByName(explicitType);
				var rule:IUniversalRule = (new type() as IUniversalRule);
				
				var classRule:IUniversalClassRule = (rule as IUniversalClassRule);
				if(classRule){
					var actClassName:String;
					if(asynchronous)actClassName = subjectDescription.parameter.(@index=="2").@type;
					else actClassName = subjectDescription.parameter.(@index=="1").@type;
					classRule.actClass = ReflectionUtils.getClassByName(actClassName);
				}
				
				if(props){
					for(key in props){
						value = props[key];
						var results:Object = PROPERTY_MATCHER.exec(value);
						if(results){
							value = ObjectUtils.getProperty(actor,results[1]);
						}else{
							value = Deliterator.deliterate(value);
						}
						ObjectUtils.setProperty(rule,key,value);
					}
				}
				return rule;
			}else{
				throw new Error(REQUIRED_META_TAGS[0]+" tag requires a rule class reference");
			}
			return null;
		}
		protected static function validateProjectSettings(): void
		{
			if (!MetadataConfirmer.confirm(REQUIRED_META_TAGS,MetadataTest))
			{
				var msg: String = "Your project settings aren't compatible with the UniversalMetadataUtil. ";
				msg += "Please ensure you have '-keep-as3-metadata+=";
				msg += REQUIRED_META_TAGS.join(",");
				msg += "' in your \"Additional Compiler Arguments\"";
				throw new Error(msg);
			}
		}
	}
}
class MetadataTest
{
	[ActRule]
	public var act: String;
}