package org.tbyrne.factories
{
	import org.tbyrne.hoborg.Cloner;

	public class SubjectClonerFactory extends BasePooledInstanceFactory
	{		
		public function get subject():Object{
			return _subject;
		}
		public function set subject(value:Object):void{
			_subject = value;
			clearCache();
		}
		
		private var _subject:Object;
		
		public function SubjectClonerFactory(subject:Object=null){
			this.subject = subject;
		}
		override protected function instantiateObject():*{
			return Cloner.clone(this.subject);
		}
		
		override public function matchesType(object:*):Boolean{
			return (object!=null) && (object["constructor"]==this.subject["constructor"]);
		}
	}
}