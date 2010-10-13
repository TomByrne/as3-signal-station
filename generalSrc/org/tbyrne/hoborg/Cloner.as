package org.tbyrne.hoborg
{
	
	import flash.utils.Dictionary;
	
	import org.tbyrne.memory.LooseReference;
	
	public class Cloner
	{
		private static var clonesToIds:Dictionary = new Dictionary(true);
		private static var idsToClones:Dictionary = new Dictionary();
		
		public static function clone(object:*, allowSelfCloneBehaviour: Boolean = true):*{
			if(object==null)return;
			var description:ObjectDescription = ObjectDescriber.describe(object);
			var cloneResult: * = null;
			var trackClone: Boolean = false;
			switch(description.classPath){
				case "String":
				case "Number":
				case "uint":
				case "int":
				case "Boolean":
					return object;
				case "Array":
					var arrObject: Array = object;
					trackClone = true;
					cloneResult = arrObject.slice();
					break;
				case "flash.utils.Dictionary":
					var dictObject: Dictionary = object;
					cloneResult = new Dictionary();
					for (var key: * in dictObject)
					{
						cloneResult[key] = dictObject[key];
					}
					trackClone = true;
					break;
				default:
					trackClone = true;
					if (object is ISelfCloning && allowSelfCloneBehaviour)
					{
						var selfCloning: ISelfCloning = object as ISelfCloning;
						cloneResult = selfCloning.clone();
					}
					else
					{
						cloneResult = Pooler.takeObject(object);
						for each(var propDesc:ObjectPropertyDescription in description.properties){
							if(propDesc.clone && propDesc.writable){
								if(propDesc.deepClone){
									cloneResult[propDesc.propertyName] = clone(object[propDesc.propertyName]);
								}else{
									cloneResult[propDesc.propertyName] = object[propDesc.propertyName];
								}
							}
						}
					}
			}
			
			if (trackClone)
			{
				var id:Number = clonesToIds[object];
				if (isNaN(id))
				{
					id = Math.random();
					clonesToIds[object] = id;
				}
				clonesToIds[cloneResult] = id;
				
				var group:Array = idsToClones[id];
				if(!group){
					//idsToClones[id] = group = [new LooseReference(object)];
					idsToClones[id] = group = [LooseReference.getNew(object)];
				}else{
					cleanGroup(group);
				}
				//group.push(new LooseReference(cloneResult));
				group.push(LooseReference.getNew(cloneResult));
			}
			
			return cloneResult;
		}
		private static const settingProps:Dictionary = new Dictionary();
		public static function setPropertyInClones(object:Object, property: String, value:*):void{
			var id:Number = clonesToIds[object];
			var idSetting:Dictionary = settingProps[id];
			if(idSetting){
				if(idSetting[property]){
					// already setting this property.
					return;
				}
			}else{
				idSetting = settingProps[id] = new Dictionary();
			}
			idSetting[property] = true;
			
			var group:Array = idsToClones[id];
			if(group){
				var i:int=0;
				while(i<group.length){
					var looseRef:LooseReference = group[i];
					if(!looseRef.referenceExists){
						group.splice(i,1);
					}else{
						var ref:Object = looseRef.reference;
						if(ref!=object){
							ref[property] = value;
						}
						i++;
					}
				}
			}
			
			delete idSetting[property];
			var found:Boolean;
			for(var obj:* in idSetting){
				found = true;
				break;
			}
			if(!found){
				delete settingProps[id];
			}
		}
		
		/**
		 * TODO: make this listen to (selected) object pools to clear ids as items are released.
		 */
		public static function areClones(object1:*,object2:*):Boolean{
			return (clonesToIds[object1]!=null && clonesToIds[object1]==clonesToIds[object2]);
		}
		protected static function onObjectReleased(e:PoolingEvent):void{
			delete clonesToIds[e.object];
		}
		protected static function cleanGroup(group:Array):void{
			var i:int=0;
			while(i<group.length){
				var looseRef:LooseReference = group[i];
				if(!looseRef.referenceExists){
					group.splice(i,1);
					looseRef.release();
				}else{
					i++;
				}
			}
		}
	}
}