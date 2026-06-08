<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>E-TECH - Account Management</title>

        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body class="dashboard-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="dashboard-container">

            <section class="filter-section">
                <div class="search-box-wrapper">
                    <label class="filter-label">Tìm kiếm</label>
                    <div class="search-input-group">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" placeholder="Tìm kiếm người dùng..">
                    </div>
                </div>

                <div class="filter-group-right">
                    <div class="filter-box-wrapper">
                        <label class="filter-label">Lọc bởi Vai trò</label>
                        <select class="filter-select">
                            <option>Tất cả vai trò</option>
                            <option>Admin</option>
                            <option>User</option>
                            <option>Employee</option>
                            <option>Shipment</option>

                        </select>
                    </div>
                    <div class="filter-box-wrapper">
                        <label class="filter-label">Lọc bởi trạng thái</label>
                        <select class="filter-select">
                            <option>Tất cả trạng thái</option>
                            <option>Hoạt động</option>
                            <option>Bị cấm</option>
                        </select>
                    </div>
                </div>
            </section>

            <section class="management-card">
                <div class="card-header-title">Quản lí người dùng</div>

                <table class="user-table">
                    <thead>
                        <tr>
                            <th style="width: 5%">#</th>
                            <th style="width: 25%">Tên</th>
                            <th style="width: 25%">Email</th>
                            <th style="width: 15%">Vai trò</th>
                            <th style="width: 12%">Trạng thái</th>
                            <th style="width: 18%">Hoạt động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>1</td>
                            <td>
                                <div class="user-info-cell">
                                    <img src="https://i.imgur.com/6VBx3io.png" class="table-avatar" alt="avatar">
                                    <span>Bui Phuc</span>
                                </div>
                            </td>
                            <td>bui.phuc.admin@gmail.com</td>
                            <td>
                                <select class="table-role-select">
                                    <option >Admin</option>
                                    

                                </select>
                            </td>
                            <td><span class="status-badge active">Hoạt động</span></td>
                            <td class="action-cell-text">Không thể cấm Admin</td>
                        </tr>

                        <tr>
                            <td>2</td>
                            <td>
                                <div class="user-info-cell">
                                    <img src="https://i.imgur.com/6VBx3io.png" class="table-avatar" alt="avatar">
                                    <span>Nguyen Van Nam</span>
                                </div>
                            </td>
                            <td>nguyenvannam@gmail.com</td>
                            <td>
                                <select class="table-role-select">
                                    <option>Admin</option>
                                    <option>User</option>
                                    <option selected>Employee</option>
                                    <option>Shipment</option>

                                </select>
                            </td>
                            <td><span class="status-badge active">Hoạt động</span></td>
                            <td>
                                <div class="action-btn-group">
                                    <button class="btn-action btn-active"><i class="fa-solid fa-check"></i> Hoạt động</button>
                                    <button class="btn-action btn-ban"><i class="fa-solid fa-ban"></i> Bị cấm</button>
                                </div>
                            </td>
                        </tr>

                        <tr>
                            <td>3</td>
                            <td>
                                <div class="user-info-cell">
                                    <img src="https://i.imgur.com/6VBx3io.png" class="table-avatar" alt="avatar">
                                    <span>Tran Minh Quan</span>
                                </div>
                            </td>
                            <td>tranminhquan@gmail.com</td>
                            <td>
                                <select class="table-role-select">
                                    <option>Admin</option>
                                    <option>User</option>
                                    <option>Employee</option>
                                    <option selected>Shipment</option>


                                </select>
                            </td>
                            <td><span class="status-badge banned">Bị cấm</span></td>
                            <td>
                                <div class="action-btn-group">
                                    <button class="btn-action btn-active"><i class="fa-solid fa-check"></i> Active</button>
                                    <button class="btn-action btn-ban" disabled><i class="fa-solid fa-ban"></i> Ban</button>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>3</td>
                            <td>
                                <div class="user-info-cell">
                                    <img src="https://i.imgur.com/6VBx3io.png" class="table-avatar" alt="avatar">
                                    <span>Le Hoang Anh</span>
                                </div>
                            </td>
                            <td>lehoanganh@gmail.com</td>
                            <td>
                                <select class="table-role-select">
                                    <option>Admin</option>
                                    <option selected>User</option>
                                    <option >Employee</option>
                                    <option>Shipment</option>

                                </select>
                            </td>
                            <td><span class="status-badge banned">Bị cấm</span></td>
                            <td>
                                <div class="action-btn-group">
                                    <button class="btn-action btn-active"><i class="fa-solid fa-check"></i> Active</button>
                                    <button class="btn-action btn-ban" disabled><i class="fa-solid fa-ban"></i> Ban</button>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>3</td>
                            <td>
                                <div class="user-info-cell">
                                    <img src="https://i.imgur.com/6VBx3io.png" class="table-avatar" alt="avatar">
                                    <span>Nguyen Ngoc Cham</span>
                                </div>
                            </td>
                            <td>phamthutrang@gmail.com</td>
                            <td>
                                <select class="table-role-select">
                                    <option>Admin</option>
                                    <option selected>User</option>
                                    <option >Employee</option>
                                    <option>Shipment</option>

                                </select>
                            </td>
                            <td><span class="status-badge banned">Bị cấm</span></td>
                            <td>
                                <div class="action-btn-group">
                                    <button class="btn-action btn-active"><i class="fa-solid fa-check"></i> Active</button>
                                    <button class="btn-action btn-ban" disabled><i class="fa-solid fa-ban"></i> Ban</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <div class="table-footer">
                    <div>1 to 10 of 2,450 users</div>

                    <ul class="pagination">
                        <li><a href="#" class="pagination-link disabled"><i class="fa-solid fa-chevron-left"></i></a></li>
                        <li><a href="#" class="pagination-link active">1</a></li>
                        <li><a href="#" class="pagination-link">2</a></li>
                        <li><a href="#" class="pagination-link">3</a></li>
                        <li><span style="padding: 0 5px;">...</span></li>
                        <li><a href="#" class="pagination-link"><i class="fa-solid fa-chevron-right"></i></a></li>
                    </ul>
                </div>
            </section>
        </main>

    </body>
</html>