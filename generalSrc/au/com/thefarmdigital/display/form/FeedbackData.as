package au.com.thefarmdigital.display.form
{
	import flash.utils.Dictionary;

	internal class FeedbackData
	{
		private var feedback: Dictionary;
		
		public function FeedbackData(targetValidationObject: *)
		{
			this.feedback = new Dictionary();
		}
		
		public function addFeedback(message: String, validationId: String = null): void
		{
			this.feedback[validationId] = message;
		}
		
		public function getFeedback(validationId: String = null): String
		{
			var message: String = null;
			message = this.feedback[validationId];
			if (message == null)
			{
				message = this.feedback[null];
			}
			return message;
		}
	}
}