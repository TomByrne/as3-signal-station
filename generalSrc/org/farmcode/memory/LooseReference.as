package org.farmcode.memory
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.IPoolable;
	import org.farmcode.hoborg.ObjectPool;
	
	public class LooseReference implements IPoolable
	{
		/*CONFIG::debug{
			private static var gettingNew:Boolean;
		}*/
		private static const pool:ObjectPool = new ObjectPool(LooseReference);
		public static function getNew(object:Object=null):LooseReference{
			/*CONFIG::debug{
				gettingNew = true;
			}*/
			var ret:LooseReference = pool.takeObject();
			/*CONFIG::debug{
				gettingNew = false;
			}*/
			ret.object = object;
			return ret;
		}
		
		
		public function get referenceExists():Boolean{
			for each(var i:Boolean in storage){
				return i;
			}
			return false;
		}
		public function get reference():Object{
			for(var i:* in storage){
				return i as Object;
			}
			return null;
		}
		
		public function set locked(value: Boolean): void
		{
			if (value != this.locked)
			{
				this._locked = value;
				if (this.locked)
				{
					this.lockedReference = this.reference;
				}
				else
				{
					this.lockedReference = null;
				}
			}
		}
		public function get locked(): Boolean{
			return this._locked;
		}
		public function set object(value:Object):void{
			for(var i:* in storage){
				delete storage[i];
			}
			storage[value] = true;
			if(_locked){
				lockedReference = value;
			}else{
				lockedReference = null;
			}
		}
		
		private var storage:Dictionary = new Dictionary(true);
		private var _locked: Boolean;
		private var lockedReference: Object;
		
		public function LooseReference(object:Object=null){
			/*CONFIG::debug{
				if(!gettingNew)throw new Error("WARNING: LooseReference should be created via LooseReference.getNew()");
			}*/
			this.lockedReference = null;
			this._locked = false;
			storage[object] = true;
		}
		public function reset():void{
			_locked = false;
			for(var i:* in storage){
				delete storage[i];
			}
			lockedReference = null;
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}
}