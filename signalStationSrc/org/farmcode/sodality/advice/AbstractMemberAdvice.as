package org.farmcode.sodality.advice
{
	public class AbstractMemberAdvice extends Advice implements IMemberAdvice
	{
		protected var _memberName: String;
		protected var _subject: Object;
		protected var _arguments: Array;
		
		public function AbstractMemberAdvice(subject:Object=null, memberName:String=null, 
			arguments:Array = null, abortable:Boolean=true)
		{
			super(abortable);
			_subject = subject;
			_memberName = memberName;
			_arguments = arguments;
		}
		
		[Property(toString="true",clonable="true")]
		public function set memberName(memberName:String):void
		{
			this._memberName = memberName;
		}
		
		public function get memberName():String
		{
			return this._memberName;
		}
		
		[Property(toString="true",clonable="true")]
		public function set subject(subject:Object):void
		{
			this._subject = subject;
		}
		
		public function get subject():Object
		{
			return this._subject;
		}
		
		[Property(toString="true",clonable="true")]
		public function set arguments(arguments:Array):void
		{
			this._arguments = arguments;
		}
		
		public function get arguments():Array
		{
			return this._arguments;
		}
	}
}