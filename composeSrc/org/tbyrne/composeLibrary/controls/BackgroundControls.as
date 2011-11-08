package org.tbyrne.composeLibrary.controls
{
	import flash.display.BitmapData;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.BitmapDataData;
	import org.tbyrne.data.core.NumberData;
	import org.tbyrne.data.dataTypes.IBitmapDataProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class BackgroundControls implements IBackgroundControls
	{
		/**
		 * @inheritDoc
		 */
		public function get backgroundColourChanged():IAct{
			return _backgroundColourProvider.numericalValueChanged;
		}
		public function get backgroundColourProvider():INumberProvider{
			return _backgroundColourProvider;
		}
		public function get backgroundColour():uint{
			return _backgroundColourProvider.numericalValue;
		}
		public function set backgroundColour(value:uint):void{
			_backgroundColourProvider.numericalValue = value;
		}
		
		
		protected var _backgroundColourProvider:NumberData = new NumberData(0);
		
		
		public function BackgroundControls()
		{
		}
	}
}