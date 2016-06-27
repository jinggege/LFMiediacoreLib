package lf.media.core.component.slider
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class LfSlider extends Sprite
	{
		
		public const E_SLIDER_CHANGE:String = "E_SLIDER_CHANGE";
		
		public function LfSlider(w:int)
		{
			super();
			
			_w = w;
			_dot = new LfSliderDot(_radius,0xCCCCCC,0xFFFFFF);
			
			_rec.width = w;
			_rec.height = 0.5;
			_rec.x = _rec.y = 0;
			
			addChild(_trackDown);
			addChild(_trackUp);
			addChild(_dot);
			
			
			_trackDown.graphics.lineStyle(2,0xCCCCCC);
			_trackDown.graphics.moveTo(0,0);
			_trackDown.graphics.lineTo(w,0);
			
			
			_dot.addEventListener(MouseEvent.MOUSE_DOWN,downHandler);
			_dot.addEventListener(MouseEvent.MOUSE_UP,upHandler);
			_dot.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
			
		}
		
		
		
		
		private function downHandler(event:MouseEvent):void{
			_dot.startDrag(true,_rec);
			_dot.addEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
		}
		
		private function upHandler(event:MouseEvent):void{
			_dot.stopDrag();
		}
		
		private function outHandler(event:MouseEvent):void{
			upHandler(null);
		}
		
		
		
		private function moveHandler(event:MouseEvent):void{
			_trackUp.graphics.clear();
			_trackUp.graphics.lineStyle(2,0xFFFFFF);
			_trackUp.graphics.moveTo(0,0);
			_trackUp.graphics.lineTo(_dot.x,0);
			
			_value = _dot.x/_w;
			this.dispatchEvent(new Event(E_SLIDER_CHANGE));
		}
		
		
		
		public function get value():Number{
			return _value;
		}
		
		
		
		
		/**
		 * num = 0------1
		 */
		public function set value(num:Number):void{
			_dot.x = num * _w;
			moveHandler(null);
		}
		
		
		
		
		
		private var _dot:LfSliderDot;
		private var _trackDown:Sprite = new Sprite();
		private var _trackUp:Sprite = new Sprite();
		private var _w:int = 50;
		
		private var _radius:int = 5;
		private var _rec:Rectangle = new Rectangle();
		private var _value:Number = 0;
		
		
		
		
		
	}
}