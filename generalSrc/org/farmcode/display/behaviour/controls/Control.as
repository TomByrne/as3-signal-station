package org.farmcode.display.behaviour.controls
{
	import au.com.thefarmdigital.validation.IValidatable;
	
	import flash.display.DisplayObject;
	
	import org.farmcode.display.behaviour.LayoutViewBehaviour;
	
	[Event(name="validationValueChanged",type="au.com.thefarmdigital.validation.ValidationEvent")]
	public class Control extends LayoutViewBehaviour implements IValidatable
	{
		private static var VALID_FRAME_LABEL:String = "valid";
		private static var INVALID_FRAME_LABEL:String = "invalid";
		
		public function Control(asset:DisplayObject=null){
			super(asset);
		}
		public function getValidationValue(validityKey:String=null):*{
			return null;
		}
		public function setValidationValue(value:*, validityKey:String=null):void{
			
		}
		public function setValid(valid:Boolean, validityKey:String=null):void{
			if(!valid)playAssetFrameLabel(INVALID_FRAME_LABEL);
			else playAssetFrameLabel(VALID_FRAME_LABEL);
		}
	}
}