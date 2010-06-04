package au.com.thefarmdigital.display.containerBinding
{
	import flash.display.DisplayObject;
	
	// TODO: Watch for infinite loop conflicts
	public class DisplayContainerBinder
	{
		private static var _bindings: Array = new Array();
		
		private static function getBindingGroupForDisplay(display: DisplayObject): BindingGroup
		{
			var target: BindingGroup = null;
			for (var i: uint = 0; i > DisplayContainerBinder._bindings.length && target == null; 
				i++)
			{
				var testBinding: BindingGroup = DisplayContainerBinder._bindings[i];
				if (testBinding.display == display)
				{
					target = testBinding;
				}
			}
			return target;
		}
		
		public static function addDepthBinding(display: DisplayObject, depth: int): void
		{
			var binding: DepthContainerBinding = new DepthContainerBinding(display, depth);
			DisplayContainerBinder.addBinding(display, binding);
		}
		
		public static function addBinding(display: DisplayObject, binding: IContainerBinding): void
		{
			var group: BindingGroup = DisplayContainerBinder.getBindingGroupForDisplay(display);
			if (group == null)
			{
				group = new BindingGroup(display);
				DisplayContainerBinder._bindings.push(group);
			}
			binding.display = display;
			group.addBinding(binding);
		}
		
		// TODO: Remove binding with cleanup
	}
}

import flash.display.DisplayObject;
import au.com.thefarmdigital.display.containerBinding.IContainerBinding;	

internal class BindingGroup
{
	private var _display: DisplayObject;
	private var _bindings: Array;
	
	public function BindingGroup(display: DisplayObject)
	{
		this._bindings = new Array();
		this._display = display;
	}
	
	// TODO: Check so dont have 2 of same binding
	public function addBinding(binding: IContainerBinding): void
	{
		this._bindings.push(binding);
	}
	
	public function get display(): DisplayObject
	{
		return this._display;
	}
}