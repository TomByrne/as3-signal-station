package org.tbyrne.compose.traits
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.collections.IndexedList;
	import org.tbyrne.compose.core.ComposeItem;

	public class TraitCollection
	{
		
		/**
		 * handler(from:TraitCollection, trait:ITrait)
		 */
		public function get traitAdded():IAct{
			return (_traitAdded || (_traitAdded = new Act()));
		}
		
		/**
		 * handler(from:TraitCollection, trait:ITrait)
		 */
		public function get traitRemoved():IAct{
			return (_traitRemoved || (_traitRemoved = new Act()));
		}
		
		protected var _traitRemoved:Act;
		protected var _traitAdded:Act;
		
		public function get traitTypeCache():Dictionary{
			return _traitTypeCache;
		}
		public function get traits():IndexedList{
			return _traits;
		}
		
		
		private var _traitTypeCache:Dictionary = new Dictionary();
		protected var _traits:IndexedList = new IndexedList();
		
		
		public function TraitCollection()
		{
		}
		
		public function getTrait(matchType:Class):*{
			if(matchType==null){
				Log.error("TraitCollection.getTrait must be supplied an ITrait class to match");
			}else{
				var cache:TraitTypeCache = validateCache(matchType);
				return cache.getTrait;
			}
		}
		public function getTraits(matchType:Class=null):Array{
			if(matchType==null){
				return _traits.list;
			}else{
				var cache:TraitTypeCache = validateCache(matchType);
				return cache.getTraits;
			}
		}
		
		public function validateCache(matchType:Class):TraitTypeCache{
			CONFIG::debug{
				if(matchType==null)Log.error("TraitCollection.validateCache must be called with a matchType");
			}
			
			var trait:ITrait;
			var invalid:IndexedList;
			
			var cache:TraitTypeCache = _traitTypeCache[matchType];
			
			if(cache){
				invalid = cache.invalid;
			}else{
				cache = new TraitTypeCache();
				_traitTypeCache[matchType] = cache;
				invalid = _traits;
			}
			if(!cache.methodCachesSafe){
				for each(trait in invalid.list){
					if(trait is matchType){
						cache.matched.add(trait);
					}
				}
				cache.invalid.clear();
				cache.methodCachesSafe = true;
				cache.getTraits = cache.matched.list;
				cache.getTrait = cache.getTraits[0];
			}
			return cache;
		}
		public function callForTraits(func:Function, matchType:Class, thisObj:ComposeItem, params:Array=null):void{
			var trait:ITrait;
			var invalid:IndexedList;
			
			var matchingType:Boolean = (matchType!=null);
			var cache:TraitTypeCache;
			if(matchingType)cache = _traitTypeCache[matchType];
			
			var realParams:Array = [thisObj,trait];
			if(params){
				realParams = realParams.concat(params);
			}
			
			if(cache){
				for each(trait in cache.matched.list){
					func.apply(null,realParams);
				}
				invalid = cache.invalid;
			}else{
				if(matchingType){
					cache = new TraitTypeCache();
					_traitTypeCache[matchType] = cache;
				}
				invalid = _traits;
			}
			if(matchingType){
				if(!cache.methodCachesSafe){
					for each(trait in invalid.list){
						if(trait is matchType){
							if(matchingType)cache.matched.add(trait);
							func.apply(null,realParams);
						}
					}
					cache.invalid.clear();
					cache.methodCachesSafe = true;
					cache.getTraits = cache.matched.list;
					cache.getTrait = cache.getTraits[0];
				}
			}else{
				for each(trait in invalid.list){
					func.apply(null,realParams);
				}
			}
		}
		public function addTrait(trait:ITrait):void{
			_traits.add(trait);
			for each(var cache:TraitTypeCache in _traitTypeCache){
				cache.invalid.add(trait);
				cache.methodCachesSafe = false;
			}
			if(_traitAdded)_traitAdded.perform(this,trait);
		}
		public function removeTrait(trait:ITrait):void{
			_traits.remove(trait);
			for each(var cache:TraitTypeCache in _traitTypeCache){
				cache.matched.remove(trait);
				cache.invalid.remove(trait);
				cache.methodCachesSafe = false;
			}
			if(_traitRemoved)_traitRemoved.perform(this,trait);
		}
	}
}
import org.tbyrne.compose.traits.ITrait;
import org.tbyrne.collections.IndexedList;

class TraitTypeCache
{
	public var methodCachesSafe:Boolean;
	public var getTrait:ITrait;
	public var getTraits:Array;
	
	public var matched:IndexedList = new IndexedList();
	public var invalid:IndexedList = new IndexedList();
}