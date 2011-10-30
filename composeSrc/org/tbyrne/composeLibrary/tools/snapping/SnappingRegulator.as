package org.tbyrne.composeLibrary.tools.snapping
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	
	public class SnappingRegulator extends AbstractTrait
	{
		private var _ignoreChanges:Boolean;
		
		private var _influences:IndexedList = new IndexedList();
		private var _traits:IndexedList = new IndexedList();
		
		private var _groups:Dictionary = new Dictionary();
		
		public function SnappingRegulator()
		{
			super();
			
			addConcern(new Concern(true,true,ISnapInfluenceTrait));
			addConcern(new Concern(true,true,ISnappableTrait));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var influence:ISnapInfluenceTrait;
			var snapTrait:ISnappableTrait;
			
			if(influence = (trait as ISnapInfluenceTrait)){
				_influences.push(influence);
				
				for each(var group:String in influence.groups){
					var list:IndexedList = _groups[group];
					if(!list){
						list = new IndexedList();
						_groups[group] = list;
					}
					list.push(influence);
				}
				
			}else if(snapTrait = (trait as ISnappableTrait)){
				_traits.push(snapTrait);
				snapTrait.snappingActiveChanged.addHandler(onSnappingActiveChanged);
				if(snapTrait.snappingActive){
					startSnapping(snapTrait);
				}
			}
		}
		
		
		private function onSnappingActiveChanged(from:ISnappableTrait):void{
			if(from.snappingActive){
				startSnapping(from);
			}else{
				stopSnapping(from);
			}
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var influence:ISnapInfluenceTrait;
			var snapTrait:ISnappableTrait;
			
			if(influence = (trait as ISnapInfluenceTrait)){
				_influences.remove(influence);
				for each(var group:String in influence.groups){
					var list:IndexedList = _groups[group];
					list.remove(influence);
				}
			}else if(snapTrait = (trait as ISnapInfluenceTrait)){
				_traits.remove(snapTrait);
				snapTrait.snappingActiveChanged.removeHandler(onSnappingActiveChanged);
				if(snapTrait.snappingActive){
					stopSnapping(snapTrait);
				}
			}
		}
		
		
		private function stopSnapping(snapTrait:ISnappableTrait):void{
			snapTrait.position3dChanged.removeHandler(onPosChanged);
		}
		private function startSnapping(snapTrait:ISnappableTrait):void{
			snapTrait.position3dChanged.addHandler(onPosChanged);
			assessSnapping(snapTrait);
		}
		private function onPosChanged(snapTrait:ISnappableTrait):void{
			if(!_ignoreChanges)assessSnapping(snapTrait);
		}
		private function assessSnapping(snapTrait:ISnappableTrait):void{
			_ignoreChanges = true;
			var influence:ISnapInfluenceTrait;
			
			var list:IndexedList = (snapTrait.snappingGroup?_groups[snapTrait.snappingGroup]:_influences);
			
			var bestProposal:Vector3D;
			var bestPropValue:Number;
			for each(influence in list){
				var proposal:Vector3D = influence.makeProposal(snapTrait);
				if(proposal){
					var propValue:Number = 0;
					var validCount:int = 0;
					for each(var influence2:ISnapInfluenceTrait in list){
						var value:Number = influence2.testProposal(snapTrait,proposal);
						if(!isNaN(value)){
							++validCount;
							propValue += value;
						}
					}
					propValue /= validCount;
					if(!bestProposal || bestPropValue>propValue){
						bestPropValue = propValue;
						bestProposal = proposal;
					}
				}
			}
			for each(influence in list){
				influence.setAcceptedProposal(snapTrait,bestProposal);
			}
			if(bestProposal){
				snapTrait.setPosition3d(bestProposal.x,bestProposal.y,bestProposal.z);
			}
			
			
			
			_ignoreChanges = false;
		}
	}
}