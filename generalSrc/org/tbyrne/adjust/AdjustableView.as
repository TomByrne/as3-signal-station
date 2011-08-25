package org.tbyrne.adjust
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.LayoutView;
	
	public class AdjustableView extends LayoutView implements IAdjustable
	{
		
		/**
		 * @inheritDoc
		 */
		public function get adjustNamesChanged():IAct{
			return ((_adjustNamesChanged) || (_adjustNamesChanged = new Act()));
		}
		
		protected var _adjustNamesChanged:Act;
		
		
		
		public function get adjustNames():Vector.<String>{
			return _adjustNames;
		}
		public function set adjustNames(value:Vector.<String>):void{
			if(_adjustNames!=value){
				_adjustNames = value;
				if(_adjustNamesChanged)_adjustNamesChanged.perform(this);
			}
		}
		public function get adjustDest():*{
			return this;
		}
		
		private var _adjustNames:Vector.<String>;
		
		public function AdjustableView(asset:IDisplayObject=null){
			super(asset);
			
		}
		
		override protected function bindToAsset() : void{
			super.bindToAsset();
			AdjustmentManager.addAdjustable(this);
		}
		override protected function unbindFromAsset() : void{
			AdjustmentManager.removeAdjustable(this);
			super.unbindFromAsset();
		}
		
		
		public function applyAdjustment(property:String, value:*):void{
			CONFIG::debug{
				var error:String = (_adjustNames?" with adjust names "+_adjustNames.join(", "):"");
				Log.trace("WARNING: Adjustable "+property+" couldn't be applied to object "+this+error);
			}
			// override me
		}
		public function clearAdjustment(property:String):void{
			// override me
			applyAdjustment(property,null);
		}
	}
}