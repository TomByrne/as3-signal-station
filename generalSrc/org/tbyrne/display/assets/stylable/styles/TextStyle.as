package org.tbyrne.display.assets.stylable.styles
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.schemaTypes.IAssetSchema;
	
	public class TextStyle extends AbstractStyle implements ITextStyle
	{
		
		public function get textFormat():TextFormat{
			return _textFormat;
		}
		public function set textFormat(value:TextFormat):void{
			if(_textFormat!=value){
				_textFormat = value;
			}
		}
		
		private var _textFormat:TextFormat;
		private var _revTextFormats:Dictionary = new Dictionary(true);
		
		
		public function TextStyle(pathPattern:String=null, stateName:String=null, textFormat:TextFormat=null){
			super(pathPattern,stateName);
			this.textFormat = textFormat;
		}
		override protected function isOverridenBy(otherStyle:IStyle):Boolean{
			var cast:TextStyle = (otherStyle as TextStyle);
			return (cast && cast.stateName==stateName);
		}
		override protected function canConcurrentApply(otherStyle:IStyle):Boolean{
			return !(otherStyle is TextStyle);
		}
		
		public function styleText(textField:TextField, oldStyles:Array):Number{
			_revTextFormats[textField] = textField.getTextFormat();
			textField.setTextFormat(_textFormat);
			textField.defaultTextFormat = _textFormat;
			return 0;
		}
		public function refreshTextStyle(textField:TextField, oldStyles:Array):Number{
			// ignore
			return 0;
		}
		public function unstyleText(textField:TextField):Number{
			var revertFormat:TextFormat = _revTextFormats[textField];
			textField.setTextFormat(revertFormat);
			textField.defaultTextFormat = revertFormat;
			return 0;
		}
	}
}