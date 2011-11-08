package org.tbyrne.composeLibrary.ui
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	import org.tbyrne.actInfo.IKeyActInfo;
	import org.tbyrne.actInfo.KeyActInfo;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display2D.types.IInteractiveObjectTrait;
	import org.tbyrne.composeLibrary.ui.types.IKeyActsTrait;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	
	public class KeyActsTrait extends AbstractTrait implements IKeyActsTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get keyPressed():IAct{
			return (_keyPressed || (_keyPressed = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get keyReleased():IAct{
			return (_keyReleased || (_keyReleased = new Act()));
		}
		
		
		
		public function get interactiveObject():InteractiveObject{
			return _interactiveObject;
		}
		public function set interactiveObject(value:InteractiveObject):void{
			if(_interactiveObject!=value){
				_interactiveObject = value;
				checkInteractiveObject();
			}
		}
		
		public function get stageMode():Boolean{
			return _stageMode;
		}
		public function set stageMode(value:Boolean):void{
			if(_stageMode!=value){
				_stageMode = value;
				checkInteractiveObject();
			}
		}
		
		private var _stageMode:Boolean;
		
		protected var _keyReleased:Act;
		protected var _keyPressed:Act;
		
		
		private var _interactiveObjectTrait:IInteractiveObjectTrait;
		private var _usedInteractiveObject:InteractiveObject;
		private var _interactiveObject:InteractiveObject;
		
		private var _keyData:Dictionary = new Dictionary();
		private var _keyLocationData:Dictionary = new Dictionary();
		private var _charData:Dictionary = new Dictionary();
		
		private var _keysDownProv:Dictionary = new Dictionary();
		private var _keyLocationsDownProv:Dictionary = new Dictionary();
		private var _charsDownProv:Dictionary = new Dictionary();
		
		private var _keysDownAct:Dictionary = new Dictionary();
		private var _keyLocationsDownAct:Dictionary = new Dictionary();
		private var _charsDownAct:Dictionary = new Dictionary();
		
		private var _keysUpAct:Dictionary = new Dictionary();
		private var _keyLocationsUpAct:Dictionary = new Dictionary();
		private var _charsUpAct:Dictionary = new Dictionary();
		
		public function KeyActsTrait(interactiveObject:InteractiveObject=null, stageMode:Boolean=false)
		{
			super();
			this.interactiveObject = interactiveObject;
			this.stageMode = stageMode;
			addConcern(new Concern(true,false,false,IInteractiveObjectTrait));
		}
		
		
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			CONFIG::debug{
				if(_interactiveObjectTrait && !_interactiveObject){
					Log.error("Two IInteractiveObjectTrait objects were found, unsure which to use");
				}
			}
			_interactiveObjectTrait = trait as IInteractiveObjectTrait;
			_interactiveObjectTrait.interactiveObjectChanged.addHandler(onInteractiveObjectChanged);
			
			checkInteractiveObject();
		}
		
		private function checkInteractiveObject():void{
			if(!_interactiveObjectTrait)return;
			
			var intObj:InteractiveObject = (_interactiveObject || _interactiveObjectTrait.interactiveObject);
			
			if(_stageMode){
				if(intObj.stage){
					intObj.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
					setInteractiveObject(intObj.stage);
				}else{
					intObj.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				}
			}else{
				intObj.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				setInteractiveObject(intObj);
			}
		}
		
		protected function onAddedToStage(event:Event):void{
			checkInteractiveObject();
		}
		
		private function setInteractiveObject(interactiveObject:InteractiveObject):void
		{
			if(_usedInteractiveObject!=interactiveObject){
				if(_usedInteractiveObject){
					_usedInteractiveObject.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					_usedInteractiveObject.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				}
				
				_usedInteractiveObject = interactiveObject;
				
				if(_usedInteractiveObject){
					_usedInteractiveObject.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					_usedInteractiveObject.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				}
			}
		}
		
		
		private function onInteractiveObjectChanged(from:IInteractiveObjectTrait):void{
			setInteractiveObject(from.interactiveObject);
		}
		
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			CONFIG::debug{
				if(trait != _interactiveObjectTrait){
					Log.error("Two IInteractiveObjectTrait objects were found, unsure which to use");
				}
			}
			if(!_interactiveObject)setInteractiveObject(null);
			
			_interactiveObjectTrait.interactiveObject.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_interactiveObjectTrait.interactiveObjectChanged.removeHandler(onInteractiveObjectChanged);
			_interactiveObjectTrait = null;
		}
		protected function onKeyDown(e:KeyboardEvent):void{
			setDataValue(_keyData,_keysDownProv,e.keyCode,true);
			setDataValue(_keyLocationData,_keyLocationsDownProv,e.keyCode+"_"+e.keyLocation,true);
			setDataValue(_charData,_charsDownProv,e.charCode,true);
			
			var actInfo:IKeyActInfo = createActInfo(e);
			performAct(_keysDownAct,e.keyCode,actInfo);
			performAct(_keyLocationsDownAct,e.keyCode+"_"+e.keyLocation,actInfo);
			performAct(_charsDownAct,e.charCode,actInfo);
			
			if(_keyPressed)_keyPressed.perform(this,actInfo);
		}
		private function createActInfo(event:KeyboardEvent):IKeyActInfo{
			var ret:KeyActInfo = new KeyActInfo(null,event.altKey,event.ctrlKey,event.shiftKey,event.charCode,event.keyCode,event.keyLocation);
			return ret;
		}
		
		protected function onKeyUp(e:KeyboardEvent):void{
			setDataValue(_keyData,_keysDownProv,e.keyCode,false);
			setDataValue(_keyLocationData,_keyLocationsDownProv,e.keyCode+"_"+e.keyLocation,false);
			setDataValue(_charData,_charsDownProv,e.charCode,false);
			
			var actInfo:IKeyActInfo = createActInfo(e);
			performAct(_keysUpAct,e.keyCode,actInfo);
			performAct(_keyLocationsUpAct,e.keyCode+"_"+e.keyLocation,actInfo);
			performAct(_charsUpAct,e.charCode,actInfo);
			
			if(_keyReleased)_keyReleased.perform(this,actInfo);
		}
		
		
		private function setDataValue(dataDict:Dictionary, downDict:Dictionary, key:*, value:Boolean):void{
			var data:BooleanData = dataDict[key];
			if(data)data.booleanValue = value;
			
			downDict[key] = value;
		}
		
		private function performAct(actDict:Dictionary, key:*, actInfo:IKeyActInfo):void{
			var act:IAct = actDict[key];
			if(act)act.perform(this,actInfo);
		}
		
		public function getKeyIsDown(keyCode:uint, keyLocation:int=-1):IBooleanProvider{
			var key:*;
			var dataLookup:Dictionary;
			var downLookup:Dictionary;
			if(keyLocation!=-1){
				key = keyCode+"_"+keyLocation;
				dataLookup = _keyLocationData;
				downLookup = _keyLocationsDownProv;
			}else{
				key = keyCode;
				dataLookup = _keyData;
				downLookup = _keysDownProv;
			}
			
			var ret:BooleanData = dataLookup[key];
			if(!ret){
				ret = new BooleanData(downLookup[key]);
				dataLookup[key] = ret;
			}
			return ret;
		}
		public function getCharIsDown(charCode:uint):IBooleanProvider{
			var ret:BooleanData = _charData[charCode];
			if(!ret){
				ret = new BooleanData(_charsDownProv[charCode]);
				_charData[charCode] = ret;
			}
			return ret;
		}
		
		
		
		public function getKeyDownAct(keyCode:uint, keyLocation:int=-1):IAct{
			var key:*;
			var dataLookup:Dictionary;
			if(keyLocation!=-1){
				key = keyCode+"_"+keyLocation;
				dataLookup = _keyLocationsDownAct;
			}else{
				key = keyCode;
				dataLookup = _keysDownAct;
			}
			
			var ret:Act = dataLookup[key];
			if(!ret){
				ret = new Act();
				dataLookup[key] = ret;
			}
			return ret;
		}
		public function getCharDownAct(charCode:uint):IAct{
			var ret:Act = _charsDownAct[charCode];
			if(!ret){
				ret = new Act();
				_charsDownAct[charCode] = ret;
			}
			return ret;
		}
		
		
		
		public function getKeyUpAct(keyCode:uint, keyLocation:int=-1):IAct{
			var key:*;
			var dataLookup:Dictionary;
			if(keyLocation!=-1){
				key = keyCode+"_"+keyLocation;
				dataLookup = _keyLocationsUpAct;
			}else{
				key = keyCode;
				dataLookup = _keysUpAct;
			}
			
			var ret:Act = dataLookup[key];
			if(!ret){
				ret = new Act();
				dataLookup[key] = ret;
			}
			return ret;
		}
		public function getCharUpAct(charCode:uint):IAct{
			var ret:Act = _charsUpAct[charCode];
			if(!ret){
				ret = new Act();
				_charsUpAct[charCode] = ret;
			}
			return ret;
		}
	}
}