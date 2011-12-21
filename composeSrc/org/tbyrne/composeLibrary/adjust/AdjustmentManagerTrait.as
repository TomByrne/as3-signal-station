package org.tbyrne.composeLibrary.adjust
{
	import org.tbyrne.adjust.Adjustment;
	import org.tbyrne.adjust.AdjustmentManager;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.adjust.types.IAdjustableTrait;
	import org.tbyrne.compose.concerns.IConcern;
	
	public class AdjustmentManagerTrait extends AbstractTrait
	{
		protected var _adjustmentManager:AdjustmentManager;
		
		public function AdjustmentManagerTrait(){
			super();
			
			_adjustmentManager = new AdjustmentManager();
			
			addConcern(new Concern(true,true,false,IAdjustableTrait,[AdjustmentManagerTrait]));
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var castTrait:IAdjustableTrait = trait as IAdjustableTrait;
			_adjustmentManager.addAdjustable(castTrait);
			
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var castTrait:IAdjustableTrait = trait as IAdjustableTrait;
			_adjustmentManager.removeAdjustable(castTrait);
		}
		
		public function addAdjustment(adjustment:Adjustment):void{
			_adjustmentManager.addAdjustment(adjustment);
		}
		public function removeAdjustment(adjustment:Adjustment):void{
			_adjustmentManager.removeAdjustment(adjustment);
		}
	}
}