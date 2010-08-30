package org.farmcode.debug.display.assets
{
	import flash.display.GradientType;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsFill;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.IAssetFactory;
	import org.farmcode.display.assets.schemaTypes.IAssetSchema;
	import org.farmcode.display.assets.stylable.StylableAsset;
	import org.farmcode.display.assets.stylable.styles.FilterStyle;
	import org.farmcode.display.assets.stylable.styles.RectangleStyle;
	import org.farmcode.display.assets.stylable.styles.TextStyle;
	import org.farmcode.display.controls.Button;
	import org.farmcode.display.controls.ToggleButton;
	
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
			debugRectStyles.push(new RectangleStyle(".*/?childList/listItem/backing",null,buttonFill));
			debugRectStyles.push(new RectangleStyle(".*/?childList/listItem/backing",Button.STATE_OVER,buttonOverFill));
			
			// TextButtons
			debugRectStyles.push(new RectangleStyle(".*/?listItem/backing",null,buttonFill,null,3));
			debugRectStyles.push(new RectangleStyle(".*/?listItem/backing",Button.STATE_OVER,buttonOverFill,null,3));
			debugRectStyles.push(new FilterStyle(".*/?listItem/backing",ToggleButton.STATE_SELECTED,[new GlowFilter(0x0033CC,0.5,2,2,2,1,true)]));
			
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