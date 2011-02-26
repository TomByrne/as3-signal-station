package org.tbyrne.styles
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.LayoutView;
	
	public class StylableView extends LayoutView implements IStylable
	{
		
		/**
		 * @inheritDoc
		 */
		public function get styleNamesChanged():IAct{
			return ((_styleNamesChanged) || (_styleNamesChanged = new Act()));
		}
		
		protected var _styleNamesChanged:Act;
		
		
		
		public function get styleNames():Vector.<String>{
			return _styleNames;
		}
		public function set styleNames(value:Vector.<String>):void{
			if(_styleNames!=value){
				_styleNames = value;
				if(_styleNamesChanged)_styleNamesChanged.perform(this);
			}
		}
		
		private var _styleNames:Vector.<String>;
		
		public function StylableView(asset:IDisplayObject=null){
			super(asset);
			
		}
		
		override protected function bindToAsset() : void{
			super.bindToAsset();
			StyleManager.addStylable(this);
		}
		override protected function unbindFromAsset() : void{
			StyleManager.removeStylable(this);
			super.unbindFromAsset();
		}
		
		
		public function applyStyle(property:String, value:*):void{
			CONFIG::debug{
				var styleStr:String = (_styleNames?" with style names "+_styleNames.join(", "):"");
				Log.trace("WARNING: Style "+property+" couldn't be applied to object "+this+styleStr);
			}
			// override me
		}
		public function clearStyle(property:String):void{
			// override me
			applyStyle(property,null);
		}
	}
}