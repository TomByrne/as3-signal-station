package org.farmcode.acting.metadata
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.metadata.ruleTypes.IUniversalClassRule;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.reactions.MethodReaction;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	import org.farmcode.compiler.MetadataConfirmer;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.reflection.Deliterator;
	import org.farmcode.reflection.ReflectionUtils;
	import org.farmcode.utils.ObjectUtils;
	
	use namespace ActingNamspace;

	public class MetadataActorRegistry
	{
		private static const REQUIRED_META_TAGS: Array = ["ActRule","ActReaction"];
		private static const DEFAULT_RULE_PACKAGE: String = "org.farmcode.acting.universal.rules.";
		private static const PROPERTY_MATCHER:RegExp = /\{([\w\.]+)\}/;
		
		private static var actMap:Dictionary = new Dictionary();
		
		public static function addActor(actor:Object, scopeDisplay:IDisplayAsset):void{
			if(!actMap[actor]){
				var classDesc: XML = ReflectionUtils.describeType(actor);
				var memberList: XMLList = classDesc.descendants().(name()=="method"||name()=="variable"||name()=="accessor");
				var acts:Array = [];
				
				var reaction:MethodReaction;
				var rule:IUniversalRule;
				for each(var memberNode:XML in memberList){
					var metaDataXML: XMLList = memberNode.metadata;
					var tot:Number = metaDataXML.length();
					reaction = null;
					
					for(var i:int=0; i<tot; ++i){
						var metaData:XML = metaDataXML[i];
						var metaName:String = metaData.attribute("name");
						switch(metaName){
							case REQUIRED_META_TAGS[0]:
								if(!reaction){
									acts.push(reaction = createImplicitReaction(actor, memberNode, scopeDisplay));
								}
								reaction.addUniversalRule(createRule(metaData,memberNode,reaction.doAsynchronous,actor));
								break;
							case REQUIRED_META_TAGS[1]:
								if(!reaction){
									acts.push(reaction = createImplicitReaction(actor, memberNode, scopeDisplay));
								}
								var paramNodes:XMLList = metaData.arg;
								var props:Dictionary;
								for each(var paramNode: XML in paramNodes){
									var key:String = paramNode.@key;
									var value:String = paramNode.@value;
									if(key!="" && value!=""){
										if(!props)props = new Dictionary();
										props[key] = value;
									}
								}
								fillObject(reaction, actor, props);
								break;
						}
					}
					// add to manager AFTER adding all reactions/rules
					if(reaction)reaction.asset = scopeDisplay;
				}
				actMap[actor] = acts;
			}else{
				throw new Error("Actor already registered");
			}
		}
		public static function createImplicitReaction(actor:Object, memberNode:XML, scopeDisplay:IDisplayAsset):MethodReaction{
			var methodName:String = memberNode.@name;
			var method:Function = actor[methodName];
			if(method==null){
				throw new Error("Method "+methodName+" could not be found/accessed");
			}
			var reaction:MethodReaction = new MethodReaction(method);
			var async:Boolean = (memberNode.parameter.length() && ReflectionUtils.getClassByName(memberNode.parameter.(@index=="1").@type)==UniversalActExecution);
			reaction.doAsynchronous = async;
			reaction.passAct = (memberNode.parameter.length());
			if(async){
				reaction.passParameters = (memberNode.parameter.length()>2);
			}else{
				reaction.passParameters = (memberNode.parameter.length()>1);
			}
			return reaction;
		}
		public static function fillObject(dest:Object, source:Object, props:Dictionary):void{
			var value:*;
			var key:String;
			if(props){
				for(key in props){
					value = props[key];
					var results:Object = PROPERTY_MATCHER.exec(value);
					if(results){
						value = ObjectUtils.getProperty(source,results[1]);
					}else{
						value = Deliterator.deliterate(value);
					}
					ObjectUtils.setProperty(dest,key,value);
				}
			}
		}
		public static function removeActor(actor:Object):void{
			var acts:Array = actMap[actor];
			if(acts){
				var tot:int = acts.length;
				for(var i:int=0; i<tot; ++i){
					var act:MethodReaction = acts[i];
					act.asset = null;
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
				
				fillObject(rule, actor, props);
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