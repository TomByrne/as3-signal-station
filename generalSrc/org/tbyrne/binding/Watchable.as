package org.tbyrne.binding
{
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import org.tbyrne.acting.actTypes.IAct;
	
	public dynamic class Watchable extends Proxy
	{
		private var _watchableProps:Dictionary;
		private var _watchablePropNames:Array;
		
		public function Watchable(watchableProperties:Array=null){
			super();
			setWatchableProps(watchableProperties);
		}
		
		override flash_proxy function setProperty(name:*, value:*):void{
			_set(name.localName, value);
		}
		override flash_proxy function getProperty(name:*):*{
			var localName:String = name.localName;
			var index:int = localName.indexOf("Changed");
			if(index==localName.length-7){
				return _getAct(localName.slice(0,localName.length-7));
			}else{
				return _get(localName);
			}
		}
		
		protected function _set(propName:String, value:*):void{
			_watchableProps[propName].value = value;
		}
		protected function _get(propName:String):*{
			return _watchableProps[propName].value;
		}
		protected function _getAct(propName:String):IAct{
			return _watchableProps[propName].changedAct;
		}
		
		protected function addWatchableProps(propName:String):void{
			CONFIG::debug{
				if(_watchableProps[propName])throw new Error("This property has already been added");
			}
			if(!_watchablePropNames)_watchablePropNames = [];
			_watchablePropNames.push(propName);
			_watchableProps[propName] = WatchableProperty.getNew();
		}
		protected function setWatchableProps(props:Array):void{
			var name:String;
			var prop:WatchableProperty;
			if(_watchableProps){
				for each(name in _watchablePropNames){
					if(props.indexOf(name)==-1){
						prop = _watchableProps[name];
						prop.release();
						delete _watchableProps[name];
					}
				}
				for each(name in props){
					if(!_watchableProps[name]){
						_watchableProps[name] = WatchableProperty.getNew();
					}
				}
			}else{
				_watchableProps = new Dictionary();
				for each(name in props){
					_watchableProps[name] = WatchableProperty.getNew();
				}
			}
			_watchablePropNames = props;
		}
	}
}
import org.tbyrne.acting.actTypes.IAct;
import org.tbyrne.acting.acts.Act;
import org.tbyrne.hoborg.IPoolable;
import org.tbyrne.hoborg.ObjectPool;

class WatchableProperty implements IPoolable{
	private static const pool:ObjectPool = new ObjectPool(WatchableProperty);
	public static function getNew():WatchableProperty{
		var ret:WatchableProperty = pool.takeObject();
		return ret;
	}
	
	
	
	/**
	 * @inheritDoc
	 * handler()
	 */
	public function get changedAct():IAct{
		if(!_changedAct)_changedAct = new Act();
		return _changedAct;
	}
	
	public function get value():*{
		return _value;
	}
	public function set value(value:*):void{
		// TODO: add test for NaN==NaN issue
		if(_value!=value){
			_value = value;
			if(_changedAct)_changedAct.perform(this);
		}
	}
	
	protected var _value:*;
	protected var _changedAct:Act;
	
	public function WatchableProperty(){
		
	}
	public function reset():void{
		if(_changedAct)_changedAct.removeAllHandlers();
	}
	public function release():void{
		pool.releaseObject(this);
	}
}