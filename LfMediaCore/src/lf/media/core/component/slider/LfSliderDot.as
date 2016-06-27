package lf.media.core.component.slider
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class LfSliderDot extends Sprite
	{
		public function LfSliderDot(radius:int,nomalColor:uint,selectColor:uint)
		{
			super();
			
			_radius          =radius; 
			_nomalColor = nomalColor;
			_selectColor  = selectColor;
			
			addChild(_bg);
			setStyle(_nomalColor);
			
			this.buttonMode = true;
			
			this.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
		}
		
		
		
		
		private function overHandler(event:MouseEvent):void{
			setStyle(_selectColor);
		}
		
		private function outHandler(event:MouseEvent):void{
			setStyle(_nomalColor);
		}
		
		
		
		public function setStyle(color:uint):void{
			_bg.graphics.clear();
			_bg.graphics.beginFill(color);
			_bg.graphics.drawCircle(0,0,_radius);
			_bg.graphics.endFill();
			
		}
		
		
		
		private var _radius:int = 10;
		private var _bg:Sprite = new Sprite();
		private var _nomalColor:uint;
		private var _selectColor:uint;
		
		
		
	}
}