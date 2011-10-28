package org.tbyrne.composeLibrary.depth
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	
	public class DepthAdjudicator extends AbstractTrait implements IDepthAdjudicator, IDepthAdjudicatorTrait
	{
		public static function createSimpleCompFunc(propName:String):Function{
			var propNameCopy:String = propName;
			var ret:Function = function(trait:ITrait):Number{
				return trait[propNameCopy];
			}
			return ret;
		}
		
		
		
		private var _traitTypes:Vector.<CompareTraitType> = new Vector.<CompareTraitType>();
		
		public function get depthAdjudicator():IDepthAdjudicator{
			return this;
		}
		
		public function DepthAdjudicator(){
		}
		
		public function compare(trait1:ITrait, trait2:ITrait):int{
			for each(var compType:CompareTraitType in _traitTypes){
				var compTrait1:* = (trait1 as compType.traitType) || trait1.item.getTrait(compType.traitType);
				if(!compTrait1)continue;
				
				var compTrait2:* = (trait2 as compType.traitType) || trait2.item.getTrait(compType.traitType);
				if(!compTrait2)continue;
				
				var prop1:Number = compType.compFunction(compTrait1);
				var prop2:Number = compType.compFunction(compTrait2);
				
				if(compType.largeIsDeep){
					return (prop1>prop2?1:(prop1<prop2?-1:0));
				}else{
					return (prop1>prop2?-1:(prop1<prop2?1:0));
				}
			}
			return 0;
		}
		
		
		public function addCompareTraitType(traitType:Class, compFunction:Function, largeIsDeep:Boolean):void{
			
			var compType:CompareTraitType = new CompareTraitType(traitType,compFunction,largeIsDeep);
			_traitTypes.push(compType);
			
		}
	}
}
class CompareTraitType{
	
	public var traitType:Class;
	public var compFunction:Function;
	public var largeIsDeep:Boolean;
	
	function CompareTraitType(traitType:Class, compFunction:Function, largeIsDeep:Boolean){
		this.traitType = traitType;
		this.compFunction = compFunction;
		this.largeIsDeep = largeIsDeep;
	}
}