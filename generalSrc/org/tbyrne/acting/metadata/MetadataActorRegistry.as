package org.tbyrne.acting.metadata
{
	import away3d.animators.data.NullAnimation;
	
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.metadata.ruleTypes.IUniversalClassRule;
	import org.tbyrne.acting.metadata.ruleTypes.IUniversalPhasedRule;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.acting.universal.reactions.MethodReaction;
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	import org.tbyrne.acting.universal.rules.CompositeActRule;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.reflection.Deliterator;
	import org.tbyrne.reflection.ReflectionUtils;
	import org.tbyrne.utils.MetadataConfirmer;
	import org.tbyrne.utils.ObjectUtils;
	
	use namespace ActingNamspace;

	public class MetadataActorRegistry
	{
		private static const REQUIRED_META_TAGS: Array = ["ActRule","ActReaction"];
		private static const DEFAULT_RULE_PACKAGE: String = "org.tbyrne.acting.universal.rules.";
		private static const PROPERTY_MATCHER:RegExp = /<([\w\.\\\/]+)>/;
		private static const PATH_DELIMITER:RegExp = /[\\\/]/;
		
		private static var metadataTested:Boolean;
		
		private static var actMap:Dictionary = new Dictionary();
		
		
		public static function addActor(actor:Object, scopeDisplay:IDisplayObject):void{
			if(!metadataTested){
				validateProjectSettings();
				metadataTested = true;
			}
			CONFIG::debug{
				if(actMap[actor]){
					Log.error( "MetadataActorRegistry.addActor: Actor already registered");
				}
			}
			var classDesc: XML = ReflectionUtils.describeType(actor);
			var memberList: XMLList = classDesc.descendants().(name()=="method"||name()=="variable"||name()=="accessor");
			var scopedObjects:Array = [];
			var classPath:String;
			
			var reaction:MethodReaction;
			for each(var memberNode:XML in memberList){
				var metaDataXML: XMLList = memberNode.metadata;
				var tot:Number = metaDataXML.length();
				reaction = null;
				var rules:Vector.<IUniversalRule> = null;
				var reactionTagFound:Boolean;
				for(var i:int=0; i<tot; ++i){
					var metaData:XML = metaDataXML[i];
					var metaName:String = metaData.attribute("name");
					switch(metaName){
						case REQUIRED_META_TAGS[0]:
							if(!reaction){
								reaction = createImplicitReaction(actor, memberNode, scopeDisplay);
							}
							if(!rules){
								rules = new Vector.<IUniversalRule>();
							}
							if(!classPath)classPath = ReflectionUtils.getClassPath(actor);
							rules.push(createRule(metaData,memberNode,reaction.doAsynchronous,actor,classPath));
							break;
						case REQUIRED_META_TAGS[1]:
							reactionTagFound = true;
							if(!reaction){
								reaction = createImplicitReaction(actor, memberNode, scopeDisplay);
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
							if(!classPath)classPath = ReflectionUtils.getClassPath(actor);
							fillObject(reaction, ReflectionUtils.getClassName(reaction), actor, props);
							break;
					}
				}
				if(rules){
					if(!reactionTagFound){
						var phases:Array = null;
						for each(var rule:IUniversalRule in rules){
							var phasedRule:IUniversalPhasedRule = (rule as IUniversalPhasedRule);
							if(phasedRule){
								var thisPhases:Array = phasedRule.phases;
								if(thisPhases){
									if(phases)phases = phases.concat(thisPhases);
									else phases = thisPhases.concat();
								}
							}
						}
						reaction.phases = phases;
					}
					scopedObjects.push(reaction);
					if(rules.length>1)reaction.addUniversalRule(new CompositeActRule(rules));
					else reaction.addUniversalRule(rules[0]);
				}
				// add to manager AFTER adding all reactions/rules
				if(reaction)reaction.asset = scopeDisplay;
			}
			actMap[actor] = scopedObjects;
		}
		public static function changeActorDisplay(actor:Object, scopeDisplay:IDisplayObject):void{
			var acts:Array = actMap[actor];
			CONFIG::debug{
				if(!acts){
					Log.error( "MetadataActorRegistry.changeActorDisplay: Actor not registered");
				}
			}
			var tot:int = acts.length;
			for(var i:int=0; i<tot; ++i){
				var act:MethodReaction = acts[i];
				act.asset = scopeDisplay;
			}
		}
		public static function removeActor(actor:Object):void{
			var acts:Array = actMap[actor];
			CONFIG::debug{
				if(!acts){
					Log.error( "MetadataActorRegistry.removeActor: Actor not registered");
				}
			}
			var tot:int = acts.length;
			for(var i:int=0; i<tot; ++i){
				var act:MethodReaction = acts[i];
				act.asset = null;
				act.removeAllUniversalRules();
			}
			delete actMap[actor];
		}
		
		
		protected static function createImplicitReaction(actor:Object, memberNode:XML, scopeDisplay:IDisplayObject):MethodReaction{
			var methodName:String = memberNode.@name;
			var method:Function = actor[methodName];
			if(method==null){
				Log.error( "MetadataActorRegistry.createImplicitReaction: Method "+methodName+" could not be found/accessed");
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
		protected static function fillObject(dest:Object, classPath:String, source:Object, props:Dictionary):void{
			var value:*;
			var key:String;
			if(props){
				for(key in props){
					value = props[key];
					var results:Object = PROPERTY_MATCHER.exec(value);
					if(results){
						value = getProperty(source,classPath,results[1]);
					}else{
						value = Deliterator.deliterate(value);
					}
					setProperty(dest,key,value);
				}
			}
		}
		public static function getProperty(from:Object, classPath:String, prop:String):*{
			if(from==null){
				return null;
			}else if(prop=="*" || prop==null){
				return from;
			}else{
				var pathParts:Array = prop.split(PATH_DELIMITER);
				
				if(pathParts.length>1){
					var scope:String;
					
					var lastPart:String = pathParts[pathParts.length-1];
					var lastDot:int = lastPart.indexOf(".");
					if(lastDot!=-1){
						pathParts[pathParts.length-1] = lastPart.substr(0,lastDot);
						prop = lastPart.substr(lastDot+1);
					}
					
					for each(var pathPart:String in pathParts){
						switch(pathPart){
							case ".":
							case "..":
								if(!scope){
									scope = classPath;
								}
								lastDot = scope.lastIndexOf(".");
								scope = scope.substr(0,lastDot);
								break;
							case "":
								break;
							default:
								if(scope){
									scope += "."+pathPart;
								}else{
									scope = pathPart;
								}
								break;
						}
					}
					from = ReflectionUtils.getClassByName(scope);
				}
				
				var parts:Array = prop.split(".");
				for(var i:int=0; i<parts.length; i++){
					from = from[parts[i]];
					if(!from)return null;
				}
				return from;
			}
		}
		public static function setProperty(into:Object, prop:String, value:*):void{
			var parts:Array = prop.split(".");
			for(var i:int=0; i<parts.length-1; i++){
				into = into[parts[i]];
			}
			into[parts[0]] = value;
		}
		protected static function createRule(triggerDescription:XML, subjectDescription:XML, asynchronous:Boolean, actor:Object, classPath:String):IUniversalRule
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
				
				fillObject(rule, classPath, actor, props);
				return rule;
			}else{
				Log.error( "MetadataActorRegistry.createRule: "+REQUIRED_META_TAGS[0]+" tag requires a rule class reference");
			}
			return null;
		}
		protected static function validateProjectSettings(): void
		{
			if (!MetadataConfirmer.confirm(REQUIRED_META_TAGS,new MetadataTest()))
			{
				var msg: String = "Your project settings aren't compatible with the UniversalMetadataUtil. ";
				msg += "Please ensure you have '-keep-as3-metadata+=";
				msg += REQUIRED_META_TAGS.join(",");
				msg += "' in your \"Additional Compiler Arguments\"";
				Log.error( "MetadataActorRegistry.validateProjectSettings: "+msg);
			}
		}
	}
}
class MetadataTest
{
	[ActRule]
	public var act: String;
	[ActReaction]
	public var actReaction: String;
}