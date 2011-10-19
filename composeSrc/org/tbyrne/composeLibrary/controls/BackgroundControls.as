package org.tbyrne.composeLibrary.controls
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.core.NumberData;
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
		
		/**
		 * @inheritDoc
		 */
		public function get backgroundAlphaChanged():IAct{
			return _backgroundAlphaProvider.numericalValueChanged;
		}
		public function get backgroundAlphaProvider():INumberProvider{
			return _backgroundAlphaProvider;
		}
		public function get backgroundAlpha():Number{
			return _backgroundAlphaProvider.numericalValue;
		}
		public function set backgroundAlpha(value:Number):void{
			_backgroundAlphaProvider.numericalValue = value;
		}
		
		protected var _backgroundColourProvider:NumberData = new NumberData(0);
		protected var _backgroundAlphaProvider:NumberData = new NumberData(1);
		
		
		public function BackgroundControls()
		{
		}
	}
}