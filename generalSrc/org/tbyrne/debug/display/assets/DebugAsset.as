package org.tbyrne.debug.display.assets
{
	import flash.display.GradientType;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsFill;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.IAssetFactory;
	import org.tbyrne.display.assets.schemaTypes.IAssetSchema;
	import org.tbyrne.display.assets.stylable.StylableAsset;
	import org.tbyrne.display.assets.stylable.styles.FilterStyle;
	import org.tbyrne.display.assets.stylable.styles.RectangleStyle;
	import org.tbyrne.display.assets.stylable.styles.TextStyle;
	import org.tbyrne.display.controls.Button;
	import org.tbyrne.display.controls.ToggleButton;
	
	use namespace DisplayNamespace;
	
	public class DebugAsset extends StylableAsset
	{
		protected static var debugRectStyles:Array
		protected static var debugTextStyles:Array
		{
			init();
		}
		protected static function init():void{
			debugRectStyles = new Array();
			debugTextStyles = new Array();
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(16,16,Math.PI/2);
			
			var buttonFill:IGraphicsFill = new GraphicsGradientFill(GradientType.LINEAR,[0xD8DAE9,0xA7A8B6,0x696C7B],[1,1,1],[0,0xe0,0xff],matrix);
			var buttonOverFill:IGraphicsFill = new GraphicsGradientFill(GradientType.LINEAR,[0xDFE1EE,0xCDCFDE,0x979AA8],[1,1,1],[0,0xe0,0xff],matrix);
			
			// cascading menu items
			const cascRegExp:String = ".*/?childList/listItem/backing";
			debugRectStyles.push(new RectangleStyle(cascRegExp,null,buttonFill));
			debugRectStyles.push(new RectangleStyle(cascRegExp,Button.STATE_OVER,buttonOverFill));
			
			// TextButtons
			const buttonRegExp:String = ".*/?((listItem)|(\w*[Bb]utton))/backing";
			debugRectStyles.push(new RectangleStyle(buttonRegExp,null,buttonFill,null,3));
			debugRectStyles.push(new RectangleStyle(buttonRegExp,Button.STATE_OVER,buttonOverFill,null,3));
			debugRectStyles.push(new FilterStyle(buttonRegExp,Button.STATE_DOWN,[new DropShadowFilter(2,45,0,0.5,1.5,1.5,1,1,true)]));
			debugRectStyles.push(new FilterStyle(buttonRegExp,ToggleButton.STATE_SELECTED,[new GlowFilter(0x0033CC,0.5,2,2,2,1,true)]));
			
			// Container
			debugRectStyles.push(new RectangleStyle(".*/?backing",null,
				new GraphicsGradientFill(GradientType.LINEAR,[0xffffff,0xDBDBDB],[1,1],[0,0xff],matrix)));
			
			// All
			debugRectStyles.push(new RectangleStyle(".",null,new GraphicsSolidFill(0,0)));
			
			
			debugTextStyles.push(new TextStyle(".",null,new TextFormat("_sans")));
			debugTextStyles.push(new FilterStyle(".",null,[new GlowFilter(0xffffff,0.25,4,4)]));
		}
		
		
		public function DebugAsset(factory:IAssetFactory=null, schema:IAssetSchema=null){
			super(factory, schema, debugTextStyles, debugRectStyles);
		}
	}
}