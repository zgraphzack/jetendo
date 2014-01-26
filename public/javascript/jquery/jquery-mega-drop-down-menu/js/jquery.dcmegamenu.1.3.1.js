/*
 * DC Mega Menu - jQuery mega menu
 * Copyright (c) 2011 Design Chemical
 *
 * Dual licensed under the MIT and GPL licenses:
 * 	http://www.opensource.org/licenses/mit-license.php
 * 	http://www.gnu.org/licenses/gpl.html
 *
 */

(function($){

	//define the defaults for the plugin and how to call it	
	$.fn.dcMegaMenu = function(options){
		//set default options  
		var defaults = {
			classParent: 'zdc-mega',
			rowItems: 3,
			speed: 'fast',
			effect: 'fade',
			classSubParent: 'zdc-mega-hdr',
			classSubLink: 'zdc-mega-hdr'
		};

		function zForceMegaOver(a){
			var subNav = $('.zdc-sub',a);
			$(a).addClass('zdc-mega-hover');
			if(defaults.effect == 'fade'){
				$(subNav).fadeIn(defaults.speed);
			}
			if(defaults.effect == 'slide'){
				$(subNav).slideDown(defaults.speed);
			}
		}
		function zForceMegaOut(a){
			var subNav = $('.zdc-sub',a);
			$(a).removeClass('zdc-mega-hover');
			if(defaults.effect == 'fade'){
				$(subNav).fadeOut(defaults.speed);
			}
			if(defaults.effect == 'slide'){
				$(subNav).slideUp(defaults.speed);
			}
			//$(subNav).hide();
		}
		//call in the default otions
		var options = $.extend(defaults, options);
		var $dcMegaMenuObj = this;
		this.css("display","block");
		//act upon the element that is passed into the design    
		return $dcMegaMenuObj.each(function(options){

			megaSetup();
			
			function megaOver(){
				var d=$('.zdc-mega',this);
				if(d.length){
					d=d.position();
					var h=$('.zdc-mega',this).height();
					var subNav2 = $(this).find('.zdc-sub-container');
					//$('.zdc-sub-container',this).css('left',parentLeft+'px').css('margin-left',-marginLeft+'px');
					var subNav = $('.zdc-sub',this);
					$(this).addClass('zdc-mega-hover');
					//alert(d.left+":"+d.top);
					subNav2.css("left",d.left);//.css("top",d.top);
					if(defaults.effect == 'fade'){
						$(subNav).fadeIn(defaults.speed);
					}
					if(defaults.effect == 'slide'){
						$(subNav).slideDown(defaults.speed);
					}
				}
			}
			
			function megaOut(){
				var subNav = $('.zdc-sub',this);
				$(this).removeClass('zdc-mega-hover');
				//$(subNav).hide();
				if(defaults.effect == 'fade'){
					$(subNav).fadeOut(defaults.speed);
				}
				if(defaults.effect == 'slide'){
					$(subNav).slideUp(defaults.speed);
				}
			}

			function megaSetup(){
				$arrow = '<span class="zdc-mega-icon"></span>';
				var classParentLi = defaults.classParent+'-li';
				var menuWidth = $($dcMegaMenuObj).outerWidth(true);
				$('> li',$dcMegaMenuObj).each(function(){
					//Set Width of sub
					var mainSub = $('> ul',this);
					var primaryLink = $('> a',this);
					if((zIsTouchscreen()) && mainSub.length != 0){
						primaryLink[0].onclick=function(){ 
							if(typeof zMegaMenuMobileDisabled == "undefined" || zMegaMenuMobileDisabled==false){
								if(this.parentNode.className.indexOf("zdc-mega-hover") != -1){
									//zForceMegaOver(this.parentNode);
									return zContentTransition.doLinkOnClick(this);
								}else{
									for(var i2=0;i2<zOpenMenuCache.length;i2++){
										zForceMegaOut(zOpenMenuCache[i2]);
									}
									zOpenMenuCache=[];
									zForceMegaOver(this.parentNode);
									zOpenMenuCache.push(this.parentNode);
								}
								return false;
							}else{
								return zContentTransition.doLinkOnClick(this);
							}
						}
					}
					if($(mainSub).length > 0){
						$(primaryLink).addClass(defaults.classParent).append($arrow);
						$(mainSub).addClass('zdc-sub').wrap('<div class="zdc-sub-container" />');
						
						var position = $(this).position();
						parentLeft = position.left;
							
						if($('ul',mainSub).length > 0){
							$(this).addClass(classParentLi);
							$('.zdc-sub-container',this).addClass('zdc-mega');
							$('> li',mainSub).each(function(){
								$(this).addClass('zdc-megaunit');
								if($('> ul',this).length){
									$(this).addClass(defaults.classSubParent);
									$('> a',this).addClass(defaults.classSubParent+'-a');
								} else {
									$(this).addClass(defaults.classSubLink);
									$('> a',this).addClass(defaults.classSubLink+'-a');
								}
							});

							// Create Rows
							var hdrs = $('.zdc-megaunit',this);
							rowSize = parseInt(defaults.rowItems);
							for(var i = 0; i < hdrs.length; i+=rowSize){
								hdrs.slice(i, i+rowSize).wrapAll('<div class="zdc-row" />');
							}

							// Get Sub Dimensions & Set Row Height
							$(mainSub).show();
							
							// Get Position of Parent Item
							var parentWidth = $(this).width();
							var parentRight = parentLeft + parentWidth;
							
							// Check available right margin
							var marginRight = menuWidth - parentRight;
							
							// // Calc Width of Sub Menu
							var subWidth = $(mainSub).outerWidth(true);
							var totalWidth = $(mainSub).parent('.zdc-sub-container').outerWidth(true);
							var containerPad = totalWidth - subWidth;
							var itemWidth = $('.zdc-megaunit',mainSub).outerWidth(true);
							var rowItems = $('.zdc-row:eq(0) .zdc-megaunit',mainSub).length;
							var innerItemWidth = itemWidth * rowItems;
							var totalItemWidth = innerItemWidth + containerPad;
							
							// Set mega header height
							$('.zdc-row',this).each(function(){
								$('.zdc-megaunit:last',this).addClass('zdc-last');
								var maxValue = undefined;
								$('.zdc-megaunit > a',this).each(function(){
									var val = parseInt($(this).height());
									if (maxValue === undefined || maxValue < val){
										maxValue = val;
									}
								});
								$('.zdc-megaunit > a',this).css('height',maxValue+'px');
								$(this).css('width',innerItemWidth+'px');
							});
							
							// // Calc Required Left Margin incl additional required for right align
							var marginLeft = (totalItemWidth - parentWidth)/2;
							if(marginRight < marginLeft){
								marginLeft = marginLeft + marginLeft - marginRight;
							}
							var subLeft = parentLeft - marginLeft;

							// If Left Position Is Negative Set To Left Margin
							if(subLeft < 0){
								$('.zdc-sub-container',this).css('left','0');
							}else if(marginRight < marginLeft){
								$('.zdc-sub-container',this).css('right','0');
							}else {
								$('.zdc-sub-container',this).css('left',parentLeft+'px').css('margin-left',-marginLeft+'px');
							}
							
							// Calculate Row Height
							$('.zdc-row',mainSub).each(function(){
								var rowHeight = $(this).height();
								$('.zdc-megaunit',this).css('height',rowHeight+'px');
								$(this).parent('.zdc-row').css('height',rowHeight+'px');
							});
							$(mainSub).hide();
					
						} else {
							$('.zdc-sub-container',this).addClass('zdc-non-mega').css('left',parentLeft+'px');
						}
					}
				});
				// Set position of mega dropdown to bottom of main menu
				var menuHeight = $('> li > a',$dcMegaMenuObj).outerHeight(true);
				$('.zdc-sub-container',$dcMegaMenuObj).css({top: menuHeight+'px'}).css('z-index','1000');
				// HoverIntent Configuration
				var config = {
					sensitivity: 2, // number = sensitivity threshold (must be 1 or higher)
					interval: 100, // number = milliseconds for onMouseOver polling interval
					over: megaOver, // function = onMouseOver callback (REQUIRED)
					timeout: 400, // number = milliseconds delay before onMouseOut
					out: megaOut // function = onMouseOut callback (REQUIRED)
				};
				$('li',$dcMegaMenuObj).hoverIntent(config);
			}
		});
	};
})(jQuery);