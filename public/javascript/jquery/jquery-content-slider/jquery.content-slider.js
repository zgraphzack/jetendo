/**
 * Copyright (c) 2016 Jake Sutherland, http://zoic.me <zoic@zoic.me>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

( function( $ ) {
	$.fn.contentSlider = function( options ) {
		var settings = $.extend( {
			childSelector: ".slide",
			timeout: 5000,
			auto: true,
			animation: 'none',
			animationDuration: 1000,
			pager: true,
			pagerStyle: 'circles',
			nextPrevious: false,
			nextButton: "&#10093;",
			previousButton: "&#10092;",
			equalHeights: true,
			debug: false
		}, options );

		if ( settings.debug ) {
			console.log( "--- CONTENT SLIDER SETTINGS ---" );
			$.each( settings, function( key, value ) {
				console.log( key + ": " + value );
			} );
		}

		var the_window = $( window );

		// Loop through all instances of our slider and set them up individually.
		return this.each( function() {
			var slider = $( this );

			slider.html( '<div class="content-slides-container">' + slider.html() + '</div>' );
			var slidesContainer = $( '.content-slides-container', slider );

			var slides = slidesContainer.children( settings.childSelector );

			var lastSlideIndex   = 0;
			var activeSlideIndex = 0;
			var totalSlides      = slides.length;

			if ( settings.debug ) {
				console.log( "Total Slides: " + totalSlides );
			}

			var pager, previousButton, nextButton, sliderInterval;

			slider.addClass( 'content-slider' );
			slides.addClass( 'content-slide' ).hide();
			$( settings.childSelector + ':first-child', slidesContainer ).addClass( 'active' ).show();

			if ( totalSlides <= 1 ) {
				return;
			}

			slider.extend( {
				calculateHeights: function() {
					// Loop through all slides, get tallest slide, set container height.
					var containerHeight = 0;
					var sliderHeight    = slidesContainer.outerHeight();

					slides.each( function( slideIndex ) {
						var slideHeight = $( slides[ slideIndex ] ).outerHeight();

						if ( slideHeight > containerHeight ) {
							containerHeight = slideHeight;
						}
					} );

					slidesContainer.css( { "height": ( containerHeight + sliderHeight ) + "px" } );
				},
				animateSlide: function( slideIndex, lastSlideIndex, forceDirection ) {
					var forceDirection = forceDirection || 0;

					if ( slider.hasClass( 'animating' ) ) {
						// We are already animating a slide, need to wait until it has finished.
						return false;
					}

					var lastSlide    = $( slides[ lastSlideIndex ] );
					var currentSlide = $( slides[ slideIndex ] );

					if ( settings.animation == 'fade' ) {
						// Placeholder class to not allow for multiple animations at the same time.
						slider.addClass( 'animating' );

						// Fade the last slide out.
						lastSlide.removeClass( 'active' ).fadeTo( settings.animationDuration, 0, function() {
							lastSlide.hide()
						} );

						// Fade the current slide in.
						currentSlide.addClass( 'active' ).stop().fadeTo( settings.animationDuration, 1, function() {
							slider.removeClass( 'animating' );
						} );
					} else if ( settings.animation == 'slide' ) {
						slider.addClass( 'animating' );

						var lastSlideDirection    = 1;
						var currentSlideDirection = 1;

						// Determine which direction the last and current slide should animate.
						if ( forceDirection > 0 ) {
							// Force direction to slide left/forward.
							lastSlideDirection    = 1;
							currentSlideDirection = 1;
						} else if ( forceDirection < 0 ) {
							// Force direction to slide right/backward.
							lastSlideDirection    = -1;
							currentSlideDirection = -1;
						} else {
							if ( lastSlideIndex == ( totalSlides - 1 ) && slideIndex == 0 ) {
								// Going from last slide to first slide.
								if ( totalSlides == 2 ) {
									// If there are only two slides then we're on the last/second slide, it makes more sense to back instead of forward.
									lastSlideDirection    = -1;
									currentSlideDirection = -1;
								} else {
									// We have more than two slides, go left/forward.
									lastSlideDirection    = 1;
									currentSlideDirection = 1;
								}
							} else {
								if ( lastSlideIndex < slideIndex ) {
									// Going from one slide to the next, go left/forward.
									lastSlideDirection    = 1;
									currentSlideDirection = 1;
								} else if ( lastSlideIndex > slideIndex ) {
									// Going from one slide to the previous, go right/backward.
									lastSlideDirection = -1;
									currentSlideDirection = -1;
								}
							}
						}

						if ( lastSlideDirection == -1 ) {
							// Slide out last slide to the right.
							lastSlide.removeClass( 'active' ).css( { 'left': 0, 'right': 0 } ).animate( { 'left': '100%', 'right': '-100%' }, settings.animationDuration, function() {
								lastSlide.hide();
							} );
						} else {
							// Slide out last slide to the left.
							lastSlide.removeClass( 'active' ).css( { 'left': 0, 'right': 0 } ).animate( { 'left': '-100%', 'right': '100%' }, settings.animationDuration, function() {
								lastSlide.hide();
							} );
						}

						if ( currentSlideDirection == -1 ) {
							// Slide in current slide from left.
							currentSlide.addClass( 'active' ).stop( true, true ).css( { 'left': '-100%', 'right': '100%' } ).show().animate( { 'left': 0, 'right': 0 }, settings.animationDuration, function() {
								slider.removeClass( 'animating' );
							} );
						} else {
							// Slide in current slide from right.
							currentSlide.addClass( 'active' ).stop( true, true ).css( { 'left': '100%', 'right': '-100%' } ).show().animate( { 'left': 0, 'right': 0 }, settings.animationDuration, function() {
								slider.removeClass( 'animating' );
							} );
						}
					}
				},
				setActiveSlide: function( slideIndex, doAnimation, lastSlideIndex, forceDirection ) {
					var doAnimation    = typeof doAnimation !== 'undefined' ? doAnimation : true;
					var lastSlideIndex = lastSlideIndex || 0;
					var forceDirection = forceDirection || 0;

					if ( settings.debug ) {
						console.log( "--- ACTIVE SLIDE INDEX: " + activeSlideIndex + " ---" );
					}

					if ( doAnimation ) {
						if ( settings.animation == 'none' ) {
							slides.removeClass( 'active' ).hide();
							$( slides[ slideIndex ] ).addClass( 'active' ).show();
						} else {
							slider.animateSlide( slideIndex, lastSlideIndex, forceDirection );
						}
					} else {
						slides.removeClass( 'active' ).hide();
						$( slides[ slideIndex ] ).addClass( 'active' ).show();
					}

					if ( settings.pager ) {
						$( 'span', pager ).removeClass( 'active' );
						$( 'span[data-slide-index="' + slideIndex + '"]', pager ).addClass( 'active' );
					}
				},
				attachPager: function() {
					slider.append( '<div class="slider-pager ' + settings.pagerStyle + '"></div>' );

					pager = $( '.slider-pager', slider );

					slides.each( function( slideIndex ) {
						pager.append( '<span data-slide-index="' + slideIndex + '"></span>' );
					} );

					pager.on( 'click', 'span', function( event ) {
						event.preventDefault();

						if ( slider.hasClass( 'animating' ) ) {
							// We are already animating a slide, need to wait until it has finished.
							return false;
						}

						var pagerSlideIndex = $( this ).attr( 'data-slide-index' );

						if ( settings.debug ) {
							console.log( "--- PAGER CLICKED FOR SLIDE: " + pagerSlideIndex + " ---" );
						}

						if ( pagerSlideIndex == activeSlideIndex ) {
							// Don't switch slides if we clicked on the active slide pager.
							return false;
						}

						lastSlideIndex   = activeSlideIndex;
						activeSlideIndex = pagerSlideIndex;

						if ( settings.auto ) {
							slider.resetInterval();
						}

						slider.setActiveSlide( activeSlideIndex, true, lastSlideIndex );

						return false;
					} );

					if ( settings.debug ) {
						console.log( "--- SLIDE PAGER ATTACHED ---" );
					}
				},
				attachNextPreviousButtons: function() {
					slider.append( '<div class="slider-previous-button">' + settings.previousButton + '</div>' );
					slider.append( '<div class="slider-next-button">' + settings.nextButton + '</div>' );

					previousButton = $( '.slider-previous-button', slider );
					nextButton     = $( '.slider-next-button', slider );

					previousButton.on( 'click', function( event ) {
						event.preventDefault();

						if ( slider.hasClass( 'animating' ) ) {
							// We are already animating a slide, need to wait until it has finished.
							return false;
						}

						lastSlideIndex = activeSlideIndex;

						if ( activeSlideIndex == 0 ) {
							activeSlideIndex = ( totalSlides - 1 );
						} else {
							activeSlideIndex--;
						}

						if ( settings.debug ) {
							console.log( "--- PREVIOUS BUTTON CLICKED: " + activeSlideIndex + " ---" );
						}

						if ( settings.auto ) {
							slider.resetInterval();
						}

						slider.setActiveSlide( activeSlideIndex, true, lastSlideIndex, -1 );

						return false;
					} );

					nextButton.on( 'click', function( event ) {
						event.preventDefault();

						if ( slider.hasClass( 'animating' ) ) {
							// We are already animating a slide, need to wait until it has finished.
							return false;
						}

						lastSlideIndex = activeSlideIndex;

						if ( activeSlideIndex < ( totalSlides - 1 ) ) {
							activeSlideIndex++;
						} else {
							activeSlideIndex = 0;
						}

						if ( settings.debug ) {
							console.log( "--- NEXT BUTTON CLICKED: " + activeSlideIndex + " ---" );
						}

						if ( settings.auto ) {
							slider.resetInterval();
						}

						slider.setActiveSlide( activeSlideIndex, true, lastSlideIndex, 1 );

						return false;
					} );

					if ( settings.debug ) {
						console.log( "--- SLIDER NEXT PREVIOUS BUTTONS ATTACHED ---" );
					}
				},
				resetInterval: function( doAnimation ) {
					if ( settings.auto ) {
						clearInterval( sliderInterval );

						sliderInterval = setInterval( function() {
							var doAnimation = typeof doAnimation !== 'undefined' ? doAnimation : true;

							lastSlideIndex = activeSlideIndex;

							if ( activeSlideIndex < ( totalSlides - 1 ) ) {
								activeSlideIndex++;
							} else {
								if ( settings.debug ) {
									console.log( "--- SLIDE INDEX STARTING OVER ---" );
								}

								activeSlideIndex = 0;
							}

							slider.setActiveSlide( activeSlideIndex, doAnimation, lastSlideIndex );
						}, settings.timeout );

						if ( settings.debug ) {
							console.log( "--- SLIDER INTERVAL RESET ---" );
						}
					}
				}
			} );

			if ( settings.equalHeights ) {
				slider.calculateHeights();

				the_window.resize( function() {
					// Re-calculate heights when window size changes.
					slidesContainer.css( { 'height': 'auto' } );
					slider.calculateHeights()
				} );
			}

			if ( settings.pager ) {
				slider.attachPager();
			}

			if ( settings.nextPrevious ) {
				slider.attachNextPreviousButtons();
			}

			if ( settings.auto ) {
				// The first slide should not animate and be shown immediately.
				slider.resetInterval( false );
			}

			// The first slide should not animate and be shown immediately.
			slider.setActiveSlide( activeSlideIndex, false );
		} );
	}

} )( jQuery );
