package au.com.thefarmdigital.display.form
{
	import au.com.thefarmdigital.display.form.events.FormEvent;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.ValidatorError;
	
	import flash.text.TextField;
	
	public class TextFieldFeedbackForm extends Form
	{
		/**
		 * Format by just using the first item
		 */
		public static function displayFirstFeedback(items: Array): String{
			var result: String;
			if (items != null && items.length > 0) {
				result = (items[0] as ValidatorError).readableMessage;
			}
			return result?result:"";
		}
		
		/**
		 * Format by using all items
		 */
		public static function displayListFeedback(items: Array): String{
			var result: String = "";
			if (items != null && items.length > 0) {
				for (var i: uint = 0; i < items.length; ++i){
					var item:ValidatorError = items[i];
					if(item.readableMessage){
						if (result.length){
							result += "\n";
						}
						result += item.readableMessage;
					}
				}
			}
			return result;
		}
		
		protected var _feedbackField: TextField;
		protected var _formatFeedbackFunction: Function;
		protected var _feedback: String;
		
		public function TextFieldFeedbackForm(controls:Array=null)
		{
			super(controls);
			
			this._feedback = "";
			
			this._feedbackField = null;
			this.formatFeedbackFunction = TextFieldFeedbackForm.displayFirstFeedback;
		}
		
		override public function set visible(visible: Boolean): void
		{
			if (visible != this._visible)
			{
				if (this.feedbackField != null)
				{
					this.setControlVisible(this.feedbackField, this.visible);
				}
			}
			super.visible = visible;
		}
		override public function get visible(): Boolean
		{
			return super.visible;
		}
		
		public function set feedbackField(feedbackField: TextField): void{
			this._feedbackField = feedbackField;
			if(_liveValidation){
				_validate();
			}
		}
		public function get feedbackField(): TextField{
			return this._feedbackField;
		}
		
		public function set formatFeedbackFunction(to: Function): void{
			if (to != _formatFeedbackFunction){
				_formatFeedbackFunction = to;
			}
		}
		public function get formatFeedbackFunction(): Function{
			return this._formatFeedbackFunction;
		}
		
		public function set feedback(feedback: String): void {
			if (feedback == null){
				feedback == "";
			}
			if (this._feedbackField && feedback != this._feedbackField.text){
				this._feedback = feedback;
				this._feedbackField.text = this._feedback;
				this.dispatchEvent(new FormEvent(FormEvent.FEEDBACK_CHANGE));
			}
		}
		public function get feedback(): String{
			return this._feedback;
		}
		
		public function clearFeedback(delay: Number = 0): void {
			this.feedback = "";
		}
		
		override public function validate():ValidationResult{
			this.clearFeedback();
			return super.validate();
		}
		
		override protected function addErrorMessages(validationResult:ValidationResult):void{
			super.addErrorMessages(validationResult);
			if (this.formatFeedbackFunction != null){
				this.feedback = this.formatFeedbackFunction(validationResult.errors);
			}
		}
		
		override public function clear():void{
			super.clear();
			this.clearFeedback();
		}
		
	}
}