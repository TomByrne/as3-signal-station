package org.tbyrne.composeLibrary.tools.snapping
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display3D.IPosition3dTrait;
	import org.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;
	import org.tbyrne.evolvex.assembly.Allocation;
	import org.tbyrne.evolvex.assembly.constraints.JunctionConstraint;
	
	public class SnappingRegulator extends AbstractTrait implements IDrawAwareTrait
	{
		private var _ignoreChanges:Boolean;
		
		private var _influences:IndexedList = new IndexedList();
		private var _traits:IndexedList = new IndexedList();
		private var _invalid:IndexedList = new IndexedList();
		
		private var _groups:Dictionary = new Dictionary();
		
		public function SnappingRegulator()
		{
			super();
			
			addConcern(new Concern(true,true,false,ISnapInfluenceTrait));
			addConcern(new Concern(true,true,false,ISnappableTrait));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var influence:ISnapInfluenceTrait = (trait as ISnapInfluenceTrait);
			var snapTrait:ISnappableTrait = (trait as ISnappableTrait);
			
			if(influence){
				_influences.push(influence);
				
				for each(var group:String in influence.groups){
					var list:IndexedList = _groups[group];
					if(!list){
						list = new IndexedList();
						_groups[group] = list;
					}
					list.push(influence);
				}
				
			}
			if(snapTrait){
				_traits.push(snapTrait);
				var posTrait:IPosition3dTrait = trait.item.getTrait(IPosition3dTrait);
				snapTrait.snappingActiveChanged.addHandler(onSnappingActiveChanged, [posTrait]);
				if(snapTrait.snappingActive){
					startSnapping(snapTrait, posTrait);
				}
			}
		}
		
		
		private function onSnappingActiveChanged(from:ISnappableTrait, posTrait:IPosition3dTrait):void{
			if(from.snappingActive){
				startSnapping(from, posTrait);
			}else{
				stopSnapping(from, posTrait);
			}
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var influence:ISnapInfluenceTrait = (trait as ISnapInfluenceTrait);
			var snapTrait:ISnappableTrait = (trait as ISnappableTrait);
			
			if(influence){
				_influences.remove(influence);
				for each(var group:String in influence.groups){
					var list:IndexedList = _groups[group];
					list.remove(influence);
				}
			}
			if(snapTrait){
				var posTrait:IPosition3dTrait = trait.item.getTrait(IPosition3dTrait);
				_traits.remove(snapTrait);
				snapTrait.snappingActiveChanged.removeHandler(onSnappingActiveChanged);
				if(snapTrait.snappingActive){
					stopSnapping(snapTrait, posTrait);
				}
			}
		}
		
		
		private function stopSnapping(snapTrait:ISnappableTrait, posTrait:IPosition3dTrait):void{
			posTrait.position3dChanged.removeHandler(onPosChanged);
		}
		private function startSnapping(snapTrait:ISnappableTrait, posTrait:IPosition3dTrait):void{
			posTrait.position3dChanged.addHandler(onPosChanged, [snapTrait]);
			assessSnapping(snapTrait, posTrait);
		}
		private function onPosChanged(posTrait:IPosition3dTrait, snapTrait:ISnappableTrait):void{
			//if(!_ignoreChanges)assessSnapping(snapTrait, posTrait);
			if(!_ignoreChanges)_invalid.push(snapTrait);
		}
		public function tick(timeStep:Number):void{
			if(_invalid.list.length){
				for each(var snapTrait:ISnappableTrait in _invalid.list){
					var posTrait:IPosition3dTrait = snapTrait.item.getTrait(IPosition3dTrait);
					assessSnapping(snapTrait,posTrait);
				}
				_invalid.clear();
			}
		}
		private function assessSnapping(snapTrait:ISnappableTrait, posTrait:IPosition3dTrait):void{
			_ignoreChanges = true;
			var influence:ISnapInfluenceTrait;
			var pos:Vector3D;
			
			var proposals:Dictionary = new Dictionary();
			var snapMap:Dictionary = new Dictionary(); // key > influence > snapPoint
			var snapList:Dictionary;
			var key:String;
			
			for each(var snapPoint:ISnapPoint in snapTrait.snapPoints){
				var list:IndexedList = (snapPoint.snappingGroup?_groups[snapPoint.snappingGroup]:_influences);
				
				for(var i:int=0; i<list.list.length; ++i){
					influence = list.list[i];
					pos = influence.makeProposal(snapTrait,snapPoint);
					if(pos){
						key = int(pos.x+05)+"_"+int(pos.y+05)+"_"+int(pos.z+05);
						if(!proposals[key]){
							proposals[key] = pos;
							snapList = new Dictionary();
							snapMap[key] = snapList;
						}else{
							snapList = snapMap[key];
						}
						snapList[influence] = snapPoint;
					}
				}
			}
			var bestProposal:Vector3D;
			var bestProposalValue:Number;
			for each(pos in proposals){
				var propValue:Number = 0;
				var validCount:int = 0;
				for each(var influence2:ISnapInfluenceTrait in _influences.list){
					var value:Number = influence2.testProposal(snapTrait,pos);
					if(!isNaN(value)){
						++validCount;
						propValue += value;
					}
				}
				propValue /= validCount;
				if(!bestProposal || bestProposalValue>propValue){
					bestProposal = pos;
					bestProposalValue = propValue;
				}
			}
			if(bestProposal){
				key = int(bestProposal.x+05)+"_"+int(bestProposal.y+05)+"_"+int(bestProposal.z+05);
				snapList = snapMap[key];
				for each(influence in _influences.list){
					influence.setAcceptedProposal(snapTrait,bestProposal,snapList[influence]);
				}
				posTrait.setPosition3d(bestProposal.x,bestProposal.y,bestProposal.z);
			}else{
				for each(influence in _influences.list){
					influence.setAcceptedProposal(snapTrait,bestProposal,null);
				}
			}
			
			
			
			_ignoreChanges = false;
		}
	}
}