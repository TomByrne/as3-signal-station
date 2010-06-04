package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.display.controls.CheckBox;
	import au.com.thefarmdigital.display.controls.CustomButton;
	import au.com.thefarmdigital.events.CalendarEvent;
	import au.com.thefarmdigital.utils.DateParser;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.reflection.ReflectionUtils;
	
	public class Calendar extends StackView
	{
		private static var YEAR_RESTRICTION:RegExp = /^(\d\d\d\d)$/;
		private static var MONTH_RESTRICTION:RegExp = /^(\d\d\d\d)\/(\d\d)$/;
		private static var DAY_RESTRICTION:RegExp = /^(\d\d\d\d)\/(\d\d)\/(\d\d)$/;
		
		private static var COMPILABLE_CONTROLS:Object = {shownDateLabel:CheckBox,
														selectedDateLabel:CheckBox,
														yearAftButton:CustomButton,
														yearForeButton:CustomButton,
														monthAftButton:CustomButton,
														monthForeButton:CustomButton,
														dateGrid:GridView};
		private static var RENDERERS:Object = 		{dateRenderer:CheckBox,
														dayNameRenderer:CheckBox};
		
		public function get shownDateLabel():CheckBox{
			return _shownDateLabel;
		}
		public function set shownDateLabel(value:CheckBox):void{
			if(_shownDateLabel!=value){
				_shownDateLabel = value;
				_shownDateLabel.buttonMode = false;
				invalidate();
			}
		}
		public function get selectedDateLabel():CheckBox{
			return _selectedDateLabel;
		}
		public function set selectedDateLabel(value:CheckBox):void{
			if(_selectedDateLabel!=value){
				_selectedDateLabel = value;
				_selectedDateLabel.buttonMode = false;
				invalidate();
			}
		}
		public function get shownDateFormat():String{
			return _shownDateFormat;
		}
		public function set shownDateFormat(value:String):void{
			if(_shownDateFormat!=value){
				_shownDateFormat = value;
				invalidate();
			}
		}
		public function get selectedDateFormat():String{
			return _selectedDateFormat;
		}
		public function set selectedDateFormat(value:String):void{
			if(_selectedDateFormat!=value){
				_selectedDateFormat = value;
				invalidate();
			}
		}
		public function get yearAftButton():CustomButton{
			return _yearAftButton;
		}
		public function set yearAftButton(value:CustomButton):void{
			if(_yearAftButton!=value){
				if(_yearAftButton)_yearAftButton.removeEventListener(MouseEvent.CLICK,onYearAftClick);
				_yearAftButton = value;
				_yearAftButton.addEventListener(MouseEvent.CLICK,onYearAftClick);
				invalidate();
			}
		}
		public function get yearForeButton():CustomButton{
			return _yearForeButton;
		}
		public function set yearForeButton(value:CustomButton):void{
			if(_yearForeButton!=value){
				if(_yearForeButton)_yearForeButton.removeEventListener(MouseEvent.CLICK,onYearForeClick);
				_yearForeButton = value;
				_yearForeButton.addEventListener(MouseEvent.CLICK,onYearForeClick);
				invalidate();
			}
		}
		public function get monthAftButton():CustomButton{
			return _monthAftButton;
		}
		public function set monthAftButton(value:CustomButton):void{
			if(_monthAftButton!=value){
				if(_monthAftButton)_monthAftButton.removeEventListener(MouseEvent.CLICK,onMonthAftClick);
				_monthAftButton = value;
				_monthAftButton.addEventListener(MouseEvent.CLICK,onMonthAftClick);
				invalidate();
			}
		}
		public function get monthForeButton():CustomButton{
			return _monthForeButton;
		}
		public function set monthForeButton(value:CustomButton):void{
			if(_monthForeButton!=value){
				if(_monthForeButton)_monthForeButton.removeEventListener(MouseEvent.CLICK,onMonthForeClick);
				_monthForeButton = value;
				_monthForeButton.addEventListener(MouseEvent.CLICK,onMonthForeClick);
				invalidate();
			}
		}
		public function get dateGrid():GridView{
			return _dateGrid;
		}
		public function set dateGrid(value:GridView):void{
			if(_dateGrid!=value){
				_dateGrid = value;
				_dateGrid.executeChildren(checkGridChild);
				_dateGrid.columns = DateParser.DAY_NAMES_SHORT.length;
				_dateGrid.imposeCellSize = true;
				_dateRenderersChanged = true;
				_dayRenderersChanged = true;
				invalidate();
			}
		}
		public function get dateRenderer():Class{
			return _dateRenderer;
		}
		public function set dateRenderer(value:Class):void{
			if(_dateRenderer!=value){
				_dateRenderer = value;
				clearDateRenderers();
			}
		}
		public function get dayNameRenderer():Class{
			return _dayNameRenderer;
		}
		public function set dayNameRenderer(value:Class):void{
			if(_dayNameRenderer!=value){
				_dayNameRenderer = value;
				clearDayRenderers();
			}
		}
		public function get dataProvider():Array{
			return _dataProvider;
		}
		public function set dataProvider(value:Array):void{
			if(_dataProvider!=value){
				_dataProvider = value;
				_dateRenderersChanged = true
				invalidate();
			}
		}
		public function get dateField():String{
			return _dateField;
		}
		public function set dateField(value:String):void{
			if(_dateField!=value){
				_dateField = value;
				invalidate();
			}
		}
		/**
		 * The shownDate property sets/gets the month which is currently being displayed.
		 */
		public function get shownDate():Date{
			return _shownDate;
		}
		public function set shownDate(value:Date):void{
			if(_shownDate!=value){
				_shownDate = value;
				_dateRenderersChanged = true;
				invalidate();
			}
		}
		/**
		 * When the Calendar is being used to selected a date (by the user) the selectedDate property
		 * represents the date the user has selected. The default value is today (based on the user's system clock).
		 */
		public function get selectedDate():Date{
			return _selectedDate;
		}
		public function set selectedDate(value:Date):void{
			if(_selectedDate!=value){
				_selectedDate = value;
				invalidate();
			}
		}
		public function get firstColumnDay():int{
			return _firstColumnDay;
		}
		public function set firstColumnDay(value:int):void{
			if(_firstColumnDay!=value){
				_firstColumnDay = value;
				_dayRenderersChanged = true;
				invalidate();
			}
		}
		/** The restrictions property allows certain dates or ranges of dates to be unselectable.
		 * It is an array of strings which each contain an operator and a date, part of a date or a keyword.
		 * Any number of restricions can be applied.
		 * 
		 * These are the operators:
		 * < - Less than, this specifies that the user can only select dates before this one.
		 * > - More than, this specifies that the user can only select dates after this one.
		 * ! - Exclude, this specifies that the user can not select this date.
		 * 
		 * Examples:
		 * >2007 - The user will only be able to view/select dates from 2008 and after.
		 * >2007/06 - The user will only be able to view/select dates from July 2007 and after.
		 * <2008 - The user will only be able to view/select dates from 2007 and before.
		 * <2008/02/15 - The user will only be able to view/select dates from the 14th of February, 2008 and before.
		 * !2008 - The user will not be able to select dates from 2008.
		 * !2008/02 - The user will not be able to select dates from February 2008.
		 * !weekends - The user will not be able to select weekends.
		 * !weekdays - The user will not be able to select weekdays.
		 * 
		 * You can also exclude specific weekdays:
		 * !Sun
		 * !Mon
		 * !Tues
		 * !Wed
		 * !Thurs
		 * !Fri
		 * !Sat
		 */
		public function get restrictions():Array{
			return _restrictions;
		}
		public function set restrictions(value:Array):void{
			_restrictions = value;
			_restrictionsParsed = parseRectrictions(value);
			_dateRenderersChanged = true;
			invalidate();
		}
		
		private var _shownDateLabel:CheckBox;
		private var _selectedDateLabel:CheckBox;
		private var _yearAftButton:CustomButton;
		private var _yearForeButton:CustomButton;
		private var _monthAftButton:CustomButton;
		private var _monthForeButton:CustomButton;
		private var _dateGrid:GridView;
		private var _dateRenderer:Class;
		private var _dayNameRenderer:Class;
		private var _dataProvider:Array;
		private var _dateField:String;
		private var _firstColumnDay:int = 0;
		private var _restrictStart:Date;
		private var _restrictions:Array;
		private var _restrictionsParsed:Array;
		
		private var _shownDate:Date;
		private var _selectedDate:Date;
		
		private var _shownDateFormat:String = "MMMM, YYYY";
		private var _selectedDateFormat:String = "DD/MM/YY";
		
		private var _dateRenderersChanged:Boolean = true;
		private var _dayRenderersChanged:Boolean = true;
		
		public function Calendar(){
			_shownDate = new Date();
			_selectedDate = new Date();
			allowAutoSize = true;
			anchor = Anchor.TOP;
		}
		override protected function removeCompiledClips():void{
			super.removeCompiledClips();
			var length:int = container.numChildren;
			for(var i:int=0; i<length; ++i){
				var child:DisplayObject = container.getChildAt(i);
				if(child is StackView){
					var stack:StackView = (child as StackView);
					var length2:int = stack.stackLength;
					for(var j:int=0; j<length2; ++j){
						var subChild:DisplayObject = stack.getStackItem(j);
						checkSubChild(subChild);
					}
				}else if(child is GridView && child!=dateGrid){
					var grid:GridView = (child as GridView);
					grid.executeChildren(checkSubChild);
				}
			}
		}
		protected function checkSubChild(child:DisplayObject):void{
			if(child.name){
				var klass:Class = COMPILABLE_CONTROLS[child.name];
				if(klass && child is klass){
					this[child.name] = child;
				}
			}
		}
		protected function checkGridChild(child:DisplayObject):void{
			if(child.name){
				var klass:Class = RENDERERS[child.name];
				if(klass && child is klass){
					this[child.name] = ReflectionUtils.getClass(child);
					dateGrid.removeGridChild(child);
				}
			}
		}
		override protected function draw():void{
			if(direction)_dateGrid.width = width;
			else _dateGrid.height = height;
			_dateGrid.columnWidths = [(_dateGrid.width-_dateGrid.leftPadding-_dateGrid.rightPadding)/DateParser.DAY_NAMES_SHORT.length-_dateGrid.horizontalGap];
			
			super.draw();
			
			if(_selectedDateLabel)_selectedDateLabel.label = DateParser.format(_selectedDate,_selectedDateFormat);
			if(_shownDateLabel)_shownDateLabel.label = DateParser.format(_shownDate,_shownDateFormat);
			// create renderers for day names
			var columns:int = _dateGrid.columns;
			var rows:int = _dateGrid.rows;
			if(_dayRenderersChanged && _dayNameRenderer){
				for(var i:int=0; i<columns; ++i){
					var child:CheckBox = (_dateGrid.getGridChildAt(i,0) as CheckBox);
					if(!child){
						child = new _dayNameRenderer();
						if(child){
							child.buttonMode = false;
							child.label = DateParser.DAY_NAMES_SHORT[(i+_firstColumnDay)%DateParser.DAY_NAMES_SHORT.length];
							_dateGrid.addGridChild(child,i,0);
						}
					}
				}
				_dayRenderersChanged = false;
			}
			var monthLength:Number = DateParser.monthLength(_shownDate.fullYear, _shownDate.month);
			var firstDay:Number = (DateParser.getFirstDay(_shownDate.fullYear, _shownDate.month)-_firstColumnDay);
			
			
			
			// create & fill renderers for dates
			if(_dateRenderersChanged && _dateRenderer){
				// firstDay - the first column with a date in it.
				if(firstDay<0)firstDay += DateParser.DAY_NAMES_SHORT.length;

				var realRows:int = Math.ceil(monthLength/DateParser.DAY_NAMES_SHORT.length);
				// CM > New fix added to catch missing days when start of month falls at end of week 
				if (realRows * DateParser.DAY_NAMES_SHORT.length > monthLength) ++realRows;
				
				// first remove excess rows
				for(i = rows+1; i<rows; ++i){
					for(var j:int=0; j<columns; ++j){
						_dateGrid.removeGridChildAt(j,i);
					}
				}
				rows = _dateGrid.rows = realRows+1;// add 1 for the day names
				// and add new ones
				for(i=0; i<columns; ++i){
					for(j=1; j<rows; ++j){
						child = (_dateGrid.getGridChildAt(i,j) as CheckBox);
						if(!child){
							child = this.createButton();
							
							if (child)
							{
								_dateGrid.addGridChild(child,i,j);
							}
						}
						// fill dates with data (either from the dataProvider or date objects)
						if(child){
							var dayDate:Number = (((j-1)*_dateGrid.columns)+i)-firstDay+1;
							if(dayDate>0 && dayDate<=monthLength){
								var date:Date = new Date(_shownDate.fullYear, _shownDate.month, dayDate);
								child.data =  getData(date);
								child.label = date.date.toString();
								child.selected = datesMatch(date,_selectedDate);
								child.buttonMode = !isRestricted(date);
							}else{
								child.label = child.data = null;
								child.selected = false;
								child.buttonMode = false;
							}
						}
					}
				}
				_dateRenderersChanged = false;
			}else{
				// do selection only (light version of the above loop)
				for(i=0; i<columns; ++i){
					for(j=1; j<rows; ++j){
						child = (_dateGrid.getGridChildAt(i,j) as CheckBox);
						if(child){
							dayDate = (((j-1)*_dateGrid.columns)+i)-firstDay+1;
							if(dayDate>0 && dayDate<=monthLength){
								date = new Date(_shownDate.fullYear, _shownDate.month, dayDate);
								child.selected = (_selectedDate && date.fullYear==_selectedDate.fullYear && date.month==_selectedDate.month && date.date==_selectedDate.date);
							}else{
								child.selected = false;
							}
						}
					}
				}
			}
		}
		protected function createButton(): CheckBox
		{
			var button: CheckBox = new _dateRenderer();
			if (button != null)
			{
				button.addEventListener(MouseEvent.CLICK,onDateSelect);
			}
			return button;
			
		}
		protected function onDateSelect(e:MouseEvent):void{
			var button:CheckBox = (e.target as CheckBox);
			
			var data:* = button.data;
			this.dispatchDayClickEvent(data);
			
			if(button.buttonMode){
				var changed: Boolean = false;
				if(data is Date){
					_selectedDate = data as Date;
					changed = true;
				}else{
					try{
						var newDate:Date = data[_dateField];
						if(newDate){
							_selectedDate = newDate;
							changed = true;
						}
					}catch(e:Error){}
				}
				if (changed) {
					this.dispatchEvent(new Event(Event.CHANGE));
				}
				invalidate();
			}
		}
		protected function dispatchDayClickEvent(dayData: *): void
		{
			var cEvent: CalendarEvent = new CalendarEvent(CalendarEvent.DAY_CLICK);
			cEvent.day = dayData;
			this.dispatchEvent(cEvent);
		}
		protected function getData(date:Date):*{
			var ret:Array = [];
			if(_dataProvider){
				var length:int = _dataProvider.length;
				for(var i:int=0; i<length; ++i){
					var data:* = _dataProvider[i];
					var dataDate:Date = (data[_dateField] as Date)
					if(datesMatch(dataDate,date)){
						ret.push(data);
					}
				}
			}
			return ret.length?ret:date;
		}
		protected function datesMatch(date1:Date, date2:Date):Boolean{
			return (date1 && date2 && 
					date1.fullYear==date2.fullYear && 
					date1.month==date2.month && 
					date1.date==date2.date);
		}
		protected function clearDayRenderers():void{
			var length:int = _dateGrid.columns;
			for(var i:int=0; i<length; ++i){
				_dateGrid.removeGridChildAt(i,0);
			}
			_dayRenderersChanged = true;
			invalidate();
		}
		protected function clearDateRenderers():void{
			var length:int = _dateGrid.columns;
			for(var i:int=0; i<length; ++i){
				var length2:int = _dateGrid.rows;
				for(var j:int=1; j<length2; ++j){
					_dateGrid.removeGridChildAt(i,j);
				}
			}
			_dateRenderersChanged = true;
			invalidate();
		}
		protected function parseRectrictions(restrictions:Array):Array{
			var ret:Array = [];
			var length:int = restrictions.length;
			for(var i:int=0; i<length; ++i){
				var rest:String = restrictions[i];
				var op:String = rest.slice(0,1);
				var dateStr:String = rest.slice(1);
				var date:Date;
				
				if(op=="!"){
					if(DateParser.DAY_NAMES_SHORT.indexOf(dateStr)!=-1){
						ret.push(new DateRectriction(dateStr));
					}else if(dateStr==DateRectriction.EXCLUDE_WEEKDAYS || dateStr==DateRectriction.EXCLUDE_WEEKENDS){
						ret.push(new DateRectriction(dateStr));
					}else{
						date = parseDate(dateStr);
						var type:String;
						if(YEAR_RESTRICTION.test(dateStr))type=DateRectriction.EXCLUDE_YEAR;
						else if(MONTH_RESTRICTION.test(dateStr))type=DateRectriction.EXCLUDE_MONTH;
						else type=DateRectriction.EXCLUDE_DAY;
						if(date)ret.push(new DateRectriction(type,date));
					}
				}else if(op=="<"){
					date = parseDate(dateStr, false);
					if(date)ret.push(new DateRectriction(DateRectriction.LESS_THAN,date));
				}else if(op==">"){
					date = parseDate(dateStr, true);
					if(date)ret.push(new DateRectriction(DateRectriction.MORE_THAN,date));
				}
			}
			return ret;
		}
		protected function parseDate(dateStr:String, max:Boolean=false):Date{
			var result:Object = YEAR_RESTRICTION.exec(dateStr);
			if(!result){
				result = MONTH_RESTRICTION.exec(dateStr);
				if(!result){
					result = DAY_RESTRICTION.exec(dateStr);
				}
			}
			if(result && result.length>1){
				var year:Number = parseInt(result[1]);
				var month:Number = result.length>2?parseInt(result[2])-1:(max?11:0);
				var day:Number = result.length>3?parseInt(result[3]):(max?DateParser.monthLength(year,month):1);
				return new Date(year,month,day);
			}
			return null;
		}
		protected function isRestricted(date:Date):Boolean{
			if(!_restrictionsParsed)return false;
			var length:int = _restrictionsParsed.length;
			for(var i:int=0; i<length; ++i){
				var rest:DateRectriction = _restrictionsParsed[i];
				switch(rest.type){
					case DateRectriction.EXCLUDE_YEAR:
						if(date.fullYear==rest.date.fullYear)return true;
						break;
					case DateRectriction.EXCLUDE_MONTH:
						if(date.fullYear==rest.date.fullYear && date.month==rest.date.month)return true;
						break;
					case DateRectriction.EXCLUDE_DAY:
						if(datesMatch(date,rest.date))return true;
						break;
					case DateRectriction.EXCLUDE_WEEKDAYS:
						if(date.day!=0 && date.day!=6)return true;
						break;
					case DateRectriction.EXCLUDE_WEEKENDS:
						if(date.day==0 || date.day==6)return true;
						break;
					default:
						if(DateParser.DAY_NAMES_SHORT.indexOf(rest.type)==date.day)return true;
						break;
				}
			}
			return isRestrictedMonth(date);
		}
		protected function isRestrictedMonth(date:Date):Boolean{
			if(!_restrictionsParsed)return false;
			var length:int = _restrictionsParsed.length;
			for(var i:int=0; i<length; ++i){
				var rest:DateRectriction = _restrictionsParsed[i];
				var less:Boolean = (rest.type==DateRectriction.LESS_THAN);
				if(rest.type==DateRectriction.MORE_THAN || less){
					var lowDate:Date = less?rest.date:date;
					var highDate:Date = less?date:rest.date;
					if (lowDate.time<=highDate.time)return true;
				}
			}
			return false;
		}
		
		// Button handlers
		protected function onYearAftClick(e:MouseEvent):void{
			if(!isRestrictedMonth(new Date(_shownDate.fullYear+1, _shownDate.month,1))){
				_shownDate.fullYear++;
				_dateRenderersChanged = true;
				invalidate();
			}
		}
		protected function onYearForeClick(e:MouseEvent):void{
			if(!isRestrictedMonth(new Date(_shownDate.fullYear-1, _shownDate.month,DateParser.monthLength(_shownDate.fullYear-1, _shownDate.month)))){
				_shownDate.fullYear--;
				_dateRenderersChanged = true;
				invalidate();
			}
		}
		protected function onMonthAftClick(e:MouseEvent):void{
			var destYear:Number = _shownDate.fullYear;
			var destMonth:Number = _shownDate.month;
			if(destMonth<11){
				destMonth++;
			}else{
				destYear++;
				destMonth = 0;
			}
			if(!isRestrictedMonth(new Date(destYear,destMonth,1))){
				_shownDate.fullYear = destYear;
				_shownDate.month = destMonth;
				_dateRenderersChanged = true;
				invalidate();
			}
		}
		protected function onMonthForeClick(e:MouseEvent):void{
			var destYear:Number = _shownDate.fullYear;
			var destMonth:Number = _shownDate.month;
			if(destMonth>0){
				destMonth--;
			}else{
				destYear--;
				destMonth = 11;
			}
			if(!isRestrictedMonth(new Date(destYear,destMonth,DateParser.monthLength(destYear,destMonth)))){
				_shownDate.fullYear = destYear;
				_shownDate.month = destMonth;
				_dateRenderersChanged = true;
				invalidate();
			}
		}
	}
}
class DateRectriction{
	public static const MORE_THAN:String = "moreThan";
	public static const LESS_THAN:String = "lessThan";
	public static const EXCLUDE_YEAR:String = "excludeYear";
	public static const EXCLUDE_MONTH:String = "excludeMonth";
	public static const EXCLUDE_DAY:String = "excludeDay";
	public static const EXCLUDE_WEEKDAYS:String = "weekdays";
	public static const EXCLUDE_WEEKENDS:String = "weekends";
	
	public var date:Date;
	public var type:String;
	
	public function DateRectriction(type:String, date:Date=null){
		this.date = date;
		this.type = type;
	}
}