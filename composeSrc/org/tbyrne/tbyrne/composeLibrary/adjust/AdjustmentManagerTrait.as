package org.tbyrne.tbyrne.composeLibrary.adjust
{
	import org.tbyrne.adjust.Adjustment;
	import org.tbyrne.adjust.AdjustmentManager;
	import org.tbyrne.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	import org.tbyrne.tbyrne.composeLibrary.types.adjust.IAdjustableTrait;
	import org.tbyrne.tbyrne.compose.concerns.ITraitConcern;
	
	public class AdjustmentManagerTrait extends AbstractTrait
	{
		protected var _adjustmentManager:AdjustmentManager;
		
		public function AdjustmentManagerTrait(){
			super();
			
			_adjustmentManager = new AdjustmentManager();
			
			addConcern(new TraitConcern(false,true,IAdjustableTrait,[AdjustmentManagerTrait]));
		}
		
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var castTrait:IAdjustableTrait = trait as IAdjustableTrait;
			_adjustmentManager.addAdjustable(castTrait);
			
		}
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
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