(function () {
    if (typeof Chart === 'undefined') {
        return;
    }

    const data = window.adminDashboardData || {};
    const viNumber = new Intl.NumberFormat('vi-VN');
    const colors = ['#dc2626', '#2563eb', '#16a34a', '#f59e0b', '#7c3aed', '#0891b2', '#db2777', '#65a30d', '#ea580c', '#475569'];

    const labels = value => value && value.length ? value : [''];
    const values = value => value && value.length ? value : [0];
    const money = value => viNumber.format(value) + ' ₫';
    const unit = text => value => viNumber.format(value) + ' ' + text;
    const intTicks = {precision: 0, callback: value => viNumber.format(value)};

    function draw(canvasId, type, chartData, options) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) {
            return;
        }
        new Chart(canvas, {type, data: chartData, options});
    }

    function bar(canvasId, labelList, valueList, datasetLabel, backgroundColor, tooltip, horizontal) {
        draw(canvasId, 'bar', {
            labels: labels(labelList),
            datasets: [{
                label: datasetLabel,
                data: values(valueList),
                backgroundColor,
                borderRadius: 8,
                maxBarThickness: canvasId === 'orderStatusChart' ? 44 : 34
            }]
        }, {
            indexAxis: horizontal ? 'y' : 'x',
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {display: false},
                tooltip: {callbacks: {label: tooltip}}
            },
            scales: {
                x: horizontal ? {beginAtZero: true, ticks: intTicks, grid: {color: '#eef2f7'}} : {grid: {display: false}},
                y: horizontal ? {grid: {display: false}} : {beginAtZero: true, ticks: intTicks, grid: {color: '#eef2f7'}}
            }
        });
    }

    draw('revenueTimelineChart', 'line', {
        labels: data.timelineLabels || [],
        datasets: [{
            label: 'Doanh thu',
            data: data.timelineValues || [],
            borderColor: '#dc2626',
            backgroundColor: 'rgba(220, 38, 38, 0.12)',
            pointBackgroundColor: '#dc2626',
            pointRadius: 4,
            pointHoverRadius: 6,
            borderWidth: 3,
            tension: 0.35,
            fill: true
        }]
    }, {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {display: false},
            tooltip: {callbacks: {label: context => context.dataset.label + ': ' + money(context.parsed.y)}}
        },
        scales: {
            y: {beginAtZero: true, ticks: {callback: money}, grid: {color: '#eef2f7'}},
            x: {grid: {display: false}}
        }
    });

    const hasCategoryData = (data.categoryValues || []).some(value => Number(value) > 0);
    const categoryLabels = hasCategoryData ? data.categoryLabels : [''];
    draw('categorySoldProductsChart', 'pie', {
        labels: categoryLabels,
        datasets: [{
            data: hasCategoryData ? data.categoryValues : [1],
            backgroundColor: categoryLabels.map((_, index) => hasCategoryData ? colors[index % colors.length] : '#e5e7eb'),
            borderColor: '#ffffff',
            borderWidth: 2
        }]
    }, {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {position: 'bottom', display: hasCategoryData, labels: {usePointStyle: true, padding: 16}},
            tooltip: {callbacks: {label: context => hasCategoryData ? context.label + ': ' + unit('sản phẩm')(context.parsed) : unit('sản phẩm')(0)}}
        }
    });

    bar('bestSellingProductsChart', data.bestSellingLabels, data.bestSellingValues, 'Đã bán', '#dc2626',
            context => unit('sản phẩm')(context.parsed.x), true);
    bar('orderStatusChart', data.orderStatusLabels, data.orderStatusValues, 'Số lượng đơn hàng',
            labels(data.orderStatusLabels).map((_, index) => colors[(index + 1) % colors.length]),
            context => unit('đơn')(context.parsed.y), false);
})();
